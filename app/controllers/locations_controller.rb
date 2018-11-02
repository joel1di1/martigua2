class LocationsController < ApplicationController
  def create
    @location = Location.create! location_params

    redirect_to_with additionnal_params: { 'match[location_id]': @location.id }, notice: 'Lieu créé'
  end

  private

  def location_params
    params.require(:location).permit(:name, :address)
  end
end
