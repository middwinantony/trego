class SavedLocationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @saved_locations = current_user.saved_locations.order(created_at: :desc)
  end

  def create
    @saved_location = current_user.saved_locations.build(saved_location_params)

    if @saved_location.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend("saved-locations", partial: "saved_locations/location", locals: { location: @saved_location })
        end
        format.html { redirect_to saved_locations_path, notice: "Location saved successfully." }
        format.json { render json: @saved_location, status: :created }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("saved-location-form", partial: "saved_locations/form", locals: { saved_location: @saved_location })
        end
        format.html { redirect_to saved_locations_path, alert: @saved_location.errors.full_messages.join(", ") }
        format.json { render json: @saved_location.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @saved_location = current_user.saved_locations.find(params[:id])
    @saved_location.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("saved-location-#{@saved_location.id}")
      end
      format.html { redirect_to saved_locations_path, notice: "Location deleted successfully." }
      format.json { head :no_content }
    end
  end

  private

  def saved_location_params
    params.require(:saved_location).permit(:name, :address, :latitude, :longitude, :location_type)
  end
end
