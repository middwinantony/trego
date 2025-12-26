class RidesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ride, only: [:show, :update, :accept, :matching, :rate, :receipt]

  # Screen 1: Rider Home - Interactive map with "Where to?" button
  def index
    # Show all rides for current user
    if current_user.driver?
      if params[:status] == 'requested'
        # For drivers, show all requested rides in their area
        @rides = Ride.where(status: 'requested', driver_id: nil).order(created_at: :desc)
      else
        @rides = Ride.where(driver: current_user).order(created_at: :desc)
      end
    else
      # For riders, show ride home screen
      @saved_locations = current_user.saved_locations
      @recent_rides = current_user.rides_as_rider.recent.limit(5)
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

  # Screen 2: Search autocomplete (Turbo Frame)
  def search
    query = params[:q]
    mapbox_service = MapboxService.new
    @results = mapbox_service.geocode(query)
    @saved_locations = current_user.saved_locations
    @recent_destinations = current_user.recent_destinations

    respond_to do |format|
      format.turbo_stream
      format.json { render json: @results }
    end
  end

  # Screen 3: Ride Options - Show all ride types with pricing
  def new
    @ride = Ride.new(pickup: params[:pickup], dropoff: params[:dropoff])

    # Geocode locations if provided
    if @ride.pickup.present? && @ride.dropoff.present?
      @ride.geocode_locations

      # Calculate pricing for all ride types
      pricing_service = RidePricingService.new(@ride)
      @ride_options = pricing_service.calculate_all_options
    end
  end

  def create
    @ride = current_user.rides_as_rider.build(ride_params)
    @ride.status = "requested"
    @ride.requested_at = Time.current

    if @ride.save
      # Calculate fare based on distance and ride type
      @ride.update(fare: @ride.calculate_fare)

      # Try to find and notify nearby drivers
      matching_service = RideMatchingService.new(@ride)
      drivers_notified = matching_service.notify_nearby_drivers

      # Redirect to matching screen (Screen 4)
      redirect_to matching_ride_path(@ride)
    else
      @ride_options = RidePricingService.new(@ride).calculate_all_options
      render :new, status: :unprocessable_entity
    end
  end

  # Screen 4: Matching - Animated "Finding your driver..." screen
  def matching
    # This screen subscribes to ActionCable for driver assignment
    # Will auto-redirect to show when driver accepts
  end

  # Screens 5, 6, 7: Show appropriate screen based on ride status
  def show
    case @ride.status
    when 'requested'
      # Still matching - show matching screen
      render :matching
    when 'accepted'
      # Screen 5: Driver Assigned
      render :driver_assigned
    when 'in_progress'
      # Screen 6: During Ride - Already has map tracking
      # Keep existing show view
    when 'completed'
      if @ride.rating.present?
        # Already rated, show receipt
        render :receipt
      else
        # Screen 7: Trip Completion - Rating & Tip
        render :completion
      end
    when 'cancelled'
      # Show cancellation details
    end
  end

  # Handle rating submission from Screen 7
  def rate
    @rating = @ride.build_rating(rating_params)
    @rating.rater = current_user
    @rating.ratee = @ride.driver

    if @rating.save
      # Update payment with tip if provided
      if params[:tip_amount].present? && @ride.payment
        @ride.payment.update(tip_amount: params[:tip_amount])
      end

      redirect_to receipt_ride_path(@ride), notice: "Thank you for your rating!"
    else
      render :completion, status: :unprocessable_entity
    end
  end

  # Receipt view
  def receipt
    # Show final receipt with fare breakdown
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
    params.require(:ride).permit(:pickup, :dropoff, :status, :driver_id, :ride_type)
  end

  def rating_params
    params.require(:rating).permit(:score, :comment)
  end
end
