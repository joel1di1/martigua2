# frozen_string_literal: true

class Location < ApplicationRecord
  validates :name, :address, presence: true
end
