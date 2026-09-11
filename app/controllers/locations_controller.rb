# frozen_string_literal: true

class LocationsController < ApplicationController
  def create
    @location = Location.create! location_params

    respond_to do |format|
      format.html do
        redirect_with additionnal_params: { 'match[location_id]': @location.id }, notice: 'Lieu créé'
      end
      format.turbo_stream
    end
  end

  private

  def location_params
    params.expect(location: %i[name address])
  end
end
