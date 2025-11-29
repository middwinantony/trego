class RideMatchingService
  def initialize(ride)
    @ride = ride
  end

  def find_drivers
    return [] unless @ride.pickup_latitude && @ride.pickup_longitude

    User.nearby_drivers(@ride.pickup_latitude, @ride.pickup_longitude, 10)
  end

  def auto_assign_driver
    drivers = find_drivers
    return false if drivers.empty?

    # Assign to the closest driver
    closest_driver = drivers.first

    @ride.update(driver: closest_driver, status: 'accepted')

    # Broadcast notification to driver
    NotificationChannel.broadcast_to(closest_driver, {
      type: 'ride_request',
      ride_id: @ride.id,
      pickup: @ride.pickup,
      dropoff: @ride.dropoff,
      fare: @ride.fare,
      rider_name: @ride.rider.name
    })

    # Broadcast to rider that driver was found
    NotificationChannel.broadcast_to(@ride.rider, {
      type: 'driver_assigned',
      ride_id: @ride.id,
      driver_name: closest_driver.name,
      driver_phone: closest_driver.phone
    })

    true
  end

  def notify_nearby_drivers
    drivers = find_drivers

    drivers.each do |driver|
      NotificationChannel.broadcast_to(driver, {
        type: 'ride_available',
        ride_id: @ride.id,
        pickup: @ride.pickup,
        dropoff: @ride.dropoff,
        fare: @ride.fare,
        distance_km: Geocoder::Calculations.distance_between(
          [@ride.pickup_latitude, @ride.pickup_longitude],
          [driver.current_latitude, driver.current_longitude]
        ).round(2)
      })
    end

    drivers.count
  end
end
