module Admin
  class DriversController < BaseController
    def index
      @drivers = User.drivers.includes(:vehicle, :current_subscription).order(created_at: :desc)

      if params[:status] == 'pending'
        @drivers = @drivers.where(approved: false)
      elsif params[:status] == 'approved'
        @drivers = @drivers.where(approved: true)
      end
    end

    def show
      @driver = User.drivers.find(params[:id])
      @rides = @driver.rides_as_driver.order(created_at: :desc).limit(20)
    end

    def approve
      @driver = User.drivers.find(params[:id])
      @driver.update(approved: true)
      redirect_to admin_drivers_path, notice: "Driver #{@driver.name} has been approved."
    end

    def reject
      @driver = User.drivers.find(params[:id])
      @driver.update(approved: false)
      redirect_to admin_drivers_path, alert: "Driver #{@driver.name} has been rejected."
    end
  end
end
