class PagesController < ApplicationController
  def dashboard
    # Optional: show user rides, driver stats, etc.
    if current_user&.driver?
      @rides = current_user.rides_as_driver
    elsif current_user&.customer?
      @rides = current_user.rides_as_rider
    end
  end
end
