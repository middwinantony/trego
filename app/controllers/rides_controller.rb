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
    # Optionally, list available drivers
    @drivers = User.where(role: "driver", available: true)
  end

  def create
    @ride = Ride.new(ride_params)
    @ride.rider = current_user
    @ride.status = "requested"

    if @ride.save
      redirect_to @ride, notice: "Ride requested successfully"
    else
      render :new, alert: "Could not create ride"
    end
  end

  def show
    # Show ride details
  end

  def update
    # Update ride status (e.g., accepted, completed)
    if @ride.update(ride_params)
      redirect_to @ride, notice: "Ride updated"
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
