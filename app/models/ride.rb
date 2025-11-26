class Ride < ApplicationRecord
  belongs_to :rider, class_name: "User"
  belongs_to :driver, class_name: "User", optional: true
  has_one :payment

  validates :pickup, presence: true
  validates :dropoff, presence: true
  validates :status, presence: true, inclusion: { in: %w[requested accepted in_progress completed cancelled] }

  scope :pending, -> { where(status: 'requested') }
  scope :active, -> { where(status: %w[accepted in_progress]) }
  scope :completed, -> { where(status: 'completed') }
end
