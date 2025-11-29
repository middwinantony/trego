class RidesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ride, only: [:show, :update]

  def index
    # Show all rides for current user
    if current_user.role == "driver"
      @rides = Ride.where(driver: current_user)
    else
      @rides = Ride.where(rider: current_user)
    end
  end

  def new
    @ride = Ride.new
    # List available drivers with active subscriptions
    @drivers = User.where(role: "driver", available: true).select do |driver|
      driver.has_active_subscription?
    end
  end

  def create
    @ride = Ride.new(ride_params)
    @ride.rider = current_user
    @ride.status = "requested"

    if @ride.save
      # Calculate fare based on distance
      @ride.update(fare: @ride.calculate_fare)

      # Try to find and notify nearby drivers
      matching_service = RideMatchingService.new(@ride)
      drivers_notified = matching_service.notify_nearby_drivers

      if drivers_notified > 0
        redirect_to @ride, notice: "Ride requested successfully. #{drivers_notified} nearby drivers notified."
      else
        redirect_to @ride, notice: "Ride requested successfully. Waiting for available drivers."
      end
    else
      render :new, alert: "Could not create ride"
    end
  end

  def show
    # Show ride details
  end

  def update
    # Update ride status (e.g., accepted, completed)
    old_status = @ride.status

    if @ride.update(ride_params)
      # Broadcast status update via ActionCable
      @ride.broadcast_update

      # Send notification based on status change
      case @ride.status
      when 'accepted'
        NotificationChannel.broadcast_to(@ride.rider, {
          type: 'ride_accepted',
          ride_id: @ride.id,
          driver_name: @ride.driver.name,
          message: "Your ride has been accepted by #{@ride.driver.name}"
        })
      when 'in_progress'
        NotificationChannel.broadcast_to(@ride.rider, {
          type: 'ride_started',
          ride_id: @ride.id,
          message: "Your ride has started"
        })
      when 'completed'
        NotificationChannel.broadcast_to(@ride.rider, {
          type: 'ride_completed',
          ride_id: @ride.id,
          message: "Your ride has been completed. Please proceed to payment."
        })
      end

      redirect_to @ride, notice: "Ride updated successfully"
    else
      render :show, alert: "Could not update ride"
    end
  end

  private

  def set_ride
    @ride = Ride.find(params[:id])
  end

  def ride_params
    params.require(:ride).permit(:pickup, :dropoff, :status, :driver_id)
  end
end
