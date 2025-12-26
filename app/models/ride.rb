class Ride < ApplicationRecord
  belongs_to :rider, class_name: "User"
  belongs_to :driver, class_name: "User", optional: true
  has_one :payment
  has_one :rating

  enum ride_type: { economy: 'economy', comfort: 'comfort', premium: 'premium', xl: 'xl' }

  validates :pickup, presence: true
  validates :dropoff, presence: true
  validates :status, presence: true, inclusion: { in: %w[requested accepted in_progress completed cancelled] }
  validates :ride_type, presence: true

  geocoded_by :pickup, latitude: :pickup_latitude, longitude: :pickup_longitude
  after_validation :geocode_pickup, if: ->(obj){ obj.pickup.present? and obj.pickup_changed? }

  reverse_geocoded_by :dropoff_latitude, :dropoff_longitude, address: :dropoff
  after_validation :geocode_dropoff, if: ->(obj){ obj.dropoff.present? and obj.dropoff_changed? }

  scope :pending, -> { where(status: 'requested') }
  scope :active, -> { where(status: %w[accepted in_progress]) }
  scope :completed, -> { where(status: 'completed') }
  scope :recent, -> { order(created_at: :desc) }

  # Ride type multipliers for pricing
  RIDE_TYPE_MULTIPLIERS = {
    'economy' => 1.0,
    'comfort' => 1.3,
    'premium' => 1.8,
    'xl' => 1.5
  }.freeze

  # Calculate distance between pickup and dropoff
  def distance
    return nil unless pickup_latitude && pickup_longitude && dropoff_latitude && dropoff_longitude
    Geocoder::Calculations.distance_between(
      [pickup_latitude, pickup_longitude],
      [dropoff_latitude, dropoff_longitude]
    )
  end

  # Calculate estimated fare based on distance and ride type
  def calculate_fare
    dist = distance
    return 0 unless dist

    base_fare = 5.0  # $5 base fare
    per_km = 2.0     # $2 per km
    multiplier = RIDE_TYPE_MULTIPLIERS[ride_type] || 1.0

    ((base_fare + (dist * per_km)) * multiplier).round(2)
  end

  # Broadcast ride update to subscribed channels
  def broadcast_update(data = {})
    RideChannel.broadcast_to(self, {
      ride_id: id,
      status: status,
      **data
    })
  end

  private

  def geocode_pickup
    geocode
  end

  def geocode_dropoff
    result = Geocoder.search(dropoff).first
    if result
      self.dropoff_latitude = result.latitude
      self.dropoff_longitude = result.longitude
    end
  end
end
