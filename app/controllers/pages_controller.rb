class PagesController < ApplicationController
  def home
    # Landing page
  end

  def dashboard
    # Optional: show user rides, driver stats, etc.
    if current_user.role == "driver"
      @rides = Ride.where(driver: current_user)
    else
      @rides = Ride.where(rider: current_user)
    end
  end
end
