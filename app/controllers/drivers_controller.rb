class DriversController < ApplicationController
  before_action :authenticate_user!
  before_action :set_driver, only: [:show, :update]

  def index
    # Show all available drivers with active subscriptions (for rider selection)
    @drivers = User.where(role: "driver", available: true).select do |driver|
      driver.has_active_subscription?
    end
  end

  def show
    # Show a single driver profile
  end

  def update
    # Update availability - only allow if driver has active subscription
    if @driver != current_user
      redirect_to dashboard_path, alert: "Unauthorized action"
      return
    end

    if params[:user][:available] == "1" && !current_user.has_active_subscription?
      redirect_to dashboard_path, alert: "You need an active subscription to go online"
      return
    end

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
