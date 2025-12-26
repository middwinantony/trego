class RideChannel < ApplicationCable::Channel
  def subscribed
    ride = Ride.find(params[:ride_id])
    # Only allow the rider or driver to subscribe to the channel
    if current_user == ride.rider || current_user == ride.driver
      stream_for ride
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def update_location(data)
    ride = Ride.find(params[:ride_id])
    # Only drivers can update location
    if current_user == ride.driver
      RideChannel.broadcast_to(ride, {
        type: 'location_update',
        driver_latitude: data['latitude'],
        driver_longitude: data['longitude'],
        driver_id: current_user.id
      })
    end
  end

  # Broadcast driver assignment (matching -> driver_assigned)
  def self.broadcast_driver_assigned(ride)
    broadcast_to(ride, {
      type: 'driver_assigned',
      status: 'accepted',
      driver_id: ride.driver_id,
      driver_name: ride.driver.name,
      message: "Driver #{ride.driver.name} has been assigned to your ride"
    })
  end

  # Broadcast ride started (driver_assigned -> in_progress)
  def self.broadcast_ride_started(ride)
    broadcast_to(ride, {
      type: 'ride_started',
      status: 'in_progress',
      message: "Your ride has started"
    })
  end

  # Broadcast ride completed (in_progress -> completed)
  def self.broadcast_ride_completed(ride)
    broadcast_to(ride, {
      type: 'ride_completed',
      status: 'completed',
      message: "Your ride has been completed"
    })
  end

  # Broadcast ETA updates
  def self.broadcast_eta_update(ride, eta_minutes)
    broadcast_to(ride, {
      type: 'eta_update',
      eta: eta_minutes,
      message: "Driver arriving in #{eta_minutes} minutes"
    })
  end
end
