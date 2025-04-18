# frozen_string_literal: true

class LocationsController < ApplicationController
  def create
    @location = Location.create! location_params

    redirect_with additionnal_params: { 'match[location_id]': @location.id }, notice: 'Lieu créé'
  end

  private

  def location_params
    params.expect(location: %i[name address])
  end
end
