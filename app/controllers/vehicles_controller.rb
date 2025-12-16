class VehiclesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_driver
  before_action :set_vehicle, only: [:show, :edit, :update, :destroy]

  def index
    @vehicles = current_user.vehicles.order(created_at: :desc)
  end

  def show
  end

  def new
    @vehicle = current_user.vehicles.build
  end

  def create
    @vehicle = current_user.vehicles.build(vehicle_params)

    if @vehicle.save
      redirect_to dashboard_path, notice: 'Vehicle registered successfully! Waiting for admin approval.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @vehicle.update(vehicle_params)
      redirect_to dashboard_path, notice: 'Vehicle updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vehicle.destroy
    redirect_to vehicles_path, notice: 'Vehicle deleted successfully.'
  end

  private

  def set_vehicle
    @vehicle = current_user.vehicles.find(params[:id])
  end

  def vehicle_params
    params.require(:vehicle).permit(:make, :model, :plate, :color)
  end

  def ensure_driver
    unless current_user.driver?
      redirect_to root_path, alert: 'Only drivers can manage vehicles.'
    end
  end
end
