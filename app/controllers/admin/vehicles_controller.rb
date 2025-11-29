module Admin
  class VehiclesController < BaseController
    def index
      @vehicles = Vehicle.includes(:user).order(created_at: :desc)

      if params[:status] == 'pending'
        @vehicles = @vehicles.where(approved: false)
      elsif params[:status] == 'approved'
        @vehicles = @vehicles.where(approved: true)
      end
    end

    def show
      @vehicle = Vehicle.find(params[:id])
    end

    def approve
      @vehicle = Vehicle.find(params[:id])
      @vehicle.update(approved: true)
      redirect_to admin_vehicles_path, notice: "Vehicle #{@vehicle.make} #{@vehicle.model} has been approved."
    end

    def reject
      @vehicle = Vehicle.find(params[:id])
      @vehicle.update(approved: false)
      redirect_to admin_vehicles_path, alert: "Vehicle #{@vehicle.make} #{@vehicle.model} has been rejected."
    end
  end
end
