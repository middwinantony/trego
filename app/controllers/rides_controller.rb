class RidesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ride, only: [:show, :update, :accept]

  def index
    # Show all rides for current user
    if current_user.role == "driver"
      if params[:status] == 'requested'
        # For drivers, show all requested rides in their area
        @rides = Ride.where(status: 'requested', driver_id: nil).order(created_at: :desc)
      else
        @rides = Ride.where(driver: current_user).order(created_at: :desc)
      end
    else
      @rides = Ride.where(rider: current_user).order(created_at: :desc)
    end

    respond_to do |format|
      format.html
      format.json {
        render json: @rides.includes(:rider, :driver).map { |ride|
          {
            id: ride.id,
            pickup: ride.pickup,
            dropoff: ride.dropoff,
            fare: ride.fare,
            status: ride.status,
            rider_name: ride.rider.name,
            driver_id: ride.driver_id,
            created_at: ride.created_at
          }
        }
      }
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

  def accept
    unless current_user.driver?
      redirect_to root_path, alert: "Only drivers can accept rides"
      return
    end

    unless current_user.can_accept_rides?
      redirect_to dashboard_path, alert: "You must have an active subscription and be approved to accept rides"
      return
    end

    if @ride.status == 'requested'
      @ride.driver = current_user
      @ride.status = 'accepted'

      if @ride.save
        # Broadcast to customer
        NotificationChannel.broadcast_to(@ride.rider, {
          type: 'ride_accepted',
          ride_id: @ride.id,
          driver_name: current_user.name,
          message: "Your ride has been accepted by #{current_user.name}"
        })

        # Broadcast update to all drivers (remove from available rides)
        @ride.broadcast_update

        respond_to do |format|
          format.html { redirect_to @ride, notice: "Ride accepted successfully!" }
          format.json { render json: { success: true, ride_id: @ride.id, message: "Ride accepted!" } }
        end
      else
        respond_to do |format|
          format.html { redirect_to dashboard_path, alert: "Could not accept ride" }
          format.json { render json: { success: false, message: "Could not accept ride" }, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to dashboard_path, alert: "This ride is no longer available" }
        format.json { render json: { success: false, message: "Ride no longer available" }, status: :unprocessable_entity }
      end
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
