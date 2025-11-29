module Admin
  class RidesController < BaseController
    def index
      @rides = Ride.includes(:rider, :driver, :payment).order(created_at: :desc)

      if params[:status].present?
        @rides = @rides.where(status: params[:status])
      end

      @rides = @rides.page(params[:page]).per(20) if defined?(Kaminari)
    end

    def show
      @ride = Ride.find(params[:id])
    end
  end
end
