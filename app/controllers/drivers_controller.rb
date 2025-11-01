class DriversController < ApplicationController
  before_action :authenticate_user!
  before_action :set_driver, only: [:show, :update]

  def index
    # Show all available drivers (for rider selection)
    @drivers = User.where(role: "driver", available: true)
  end

  def show
    # Show a single driver profile
  end

  def update
    # Update availability
    if @driver.update(driver_params)
      redirect_to dashboard_path, notice: "Availability updated"
    else
      redirect_to dashboard_path, alert: "Could not update"
    end
  end

  private

  def set_driver
    @driver = User.find(params[:id])
  end

  def driver_params
    params.require(:user).permit(:available)
  end
end
