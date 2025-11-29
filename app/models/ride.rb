class Ride < ApplicationRecord
  belongs_to :rider, class_name: "User"
  belongs_to :driver, class_name: "User", optional: true
  has_one :payment

  validates :pickup, presence: true
  validates :dropoff, presence: true
  validates :status, presence: true, inclusion: { in: %w[requested accepted in_progress completed cancelled] }

  geocoded_by :pickup, latitude: :pickup_latitude, longitude: :pickup_longitude
  after_validation :geocode_pickup, if: ->(obj){ obj.pickup.present? and obj.pickup_changed? }

  reverse_geocoded_by :dropoff_latitude, :dropoff_longitude, address: :dropoff
  after_validation :geocode_dropoff, if: ->(obj){ obj.dropoff.present? and obj.dropoff_changed? }

  scope :pending, -> { where(status: 'requested') }
  scope :active, -> { where(status: %w[accepted in_progress]) }
  scope :completed, -> { where(status: 'completed') }

  # Calculate distance between pickup and dropoff
  def distance
    return nil unless pickup_latitude && pickup_longitude && dropoff_latitude && dropoff_longitude
    Geocoder::Calculations.distance_between(
      [pickup_latitude, pickup_longitude],
      [dropoff_latitude, dropoff_longitude]
    )
  end

  # Calculate estimated fare based on distance
  def calculate_fare
    dist = distance
    return 0 unless dist

    base_fare = 5.0  # $5 base fare
    per_km = 2.0     # $2 per km

    (base_fare + (dist * per_km)).round(2)
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
