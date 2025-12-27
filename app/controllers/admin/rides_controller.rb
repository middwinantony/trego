module Admin
  class RidesController < BaseController
    def index
      @rides = Ride.includes(:rider, :driver, :payment).order(created_at: :desc)

      if params[:status].present?
        @rides = @rides.where(status: params[:status])
      end
    end

    def show
      @ride = Ride.find(params[:id])
    end
  end
end
