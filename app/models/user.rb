class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :vehicle
  has_many :subscriptions
  has_one :current_subscription, -> { active.order(created_at: :desc) }, class_name: 'Subscription'

  has_many :rides_as_rider, class_name: 'Ride', foreign_key: 'rider_id'
  has_many :rides_as_driver, class_name: 'Ride', foreign_key: 'driver_id'

  validates :role, presence: true, inclusion: { in: %w[customer driver] }
  validates :name, presence: true
  validates :phone, presence: true

  def driver?
    role == 'driver'
  end

  def customer?
    role == 'customer'
  end

  def has_active_subscription?
    driver? && current_subscription&.active?
  end

  def can_accept_rides?
    driver? && available? && has_active_subscription?
  end
end
