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
        latitude: data['latitude'],
        longitude: data['longitude'],
        driver_id: current_user.id
      })
    end
  end
end
