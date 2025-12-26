class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :profile_photo

  has_many :vehicles
  has_many :subscriptions
  has_one :current_subscription, -> { active.order(created_at: :desc) }, class_name: 'Subscription'

  has_many :rides_as_rider, class_name: 'Ride', foreign_key: 'rider_id'
  has_many :rides_as_driver, class_name: 'Ride', foreign_key: 'driver_id'
  has_many :complaints
  has_many :kyc_documents
  has_many :saved_locations
  has_many :ratings_given, class_name: 'Rating', foreign_key: 'rater_id'
  has_many :ratings_received, class_name: 'Rating', foreign_key: 'ratee_id'

  validates :role, presence: true, inclusion: { in: %w[customer driver admin] }
  validates :name, presence: true
  validates :phone, presence: true

  scope :drivers, -> { where(role: 'driver') }
  scope :customers, -> { where(role: 'customer') }
  scope :pending_approval, -> { where(role: 'driver', approved: false) }
  scope :approved_drivers, -> { where(role: 'driver', approved: true) }

  reverse_geocoded_by :current_latitude, :current_longitude

  def driver?
    role == 'driver'
  end

  def customer?
    role == 'customer'
  end

  def admin?
    is_admin
  end

  def has_active_subscription?
    driver? && current_subscription&.active?
  end

  def can_accept_rides?
    driver? && available? && has_active_subscription? && approved?
  end

  def pending_approval?
    driver? && !approved?
  end

  # Find nearby available drivers
  def self.nearby_drivers(latitude, longitude, radius_km = 10)
    drivers
      .where(available: true, approved: true)
      .where.not(current_latitude: nil, current_longitude: nil)
      .select { |driver| driver.can_accept_rides? }
      .select do |driver|
        distance = Geocoder::Calculations.distance_between(
          [latitude, longitude],
          [driver.current_latitude, driver.current_longitude]
        )
        distance <= radius_km
      end
      .sort_by do |driver|
        Geocoder::Calculations.distance_between(
          [latitude, longitude],
          [driver.current_latitude, driver.current_longitude]
        )
      end
  end

  # Calculate total earnings for driver
  def total_earnings
    return 0 unless driver?
    rides_as_driver.completed.joins(:payment).where(payments: { status: 'succeeded' }).sum('payments.amount')
  end

  # Get earnings breakdown
  def earnings_breakdown
    return {} unless driver?

    rides = rides_as_driver.completed.joins(:payment).where(payments: { status: 'succeeded' })

    {
      total: total_earnings,
      today: rides.where('rides.created_at >= ?', Time.zone.today).sum('payments.amount'),
      this_week: rides.where('rides.created_at >= ?', Time.zone.today.beginning_of_week).sum('payments.amount'),
      this_month: rides.where('rides.created_at >= ?', Time.zone.today.beginning_of_month).sum('payments.amount'),
      total_rides: rides.count,
      average_per_ride: rides.count > 0 ? (total_earnings / rides.count).round(2) : 0
    }
  end

  # Calculate average rating from ratings received
  def average_rating
    return 0 if ratings_received.empty?
    (ratings_received.average(:score).to_f).round(1)
  end

  # Get recent destinations for rider
  def recent_destinations
    return [] unless customer?
    rides_as_rider.recent.limit(10).pluck(:dropoff).uniq.compact
  end
end
