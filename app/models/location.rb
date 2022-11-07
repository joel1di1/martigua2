# frozen_string_literal: true

class Location < ApplicationRecord
  validates :name, :address, presence: true

  def self.find_or_create_with_ffhb_location(locations)
    address = locations.join("\n")
    find_or_create_by(address:) do |location|
      location.name = address
    end
  end
end
