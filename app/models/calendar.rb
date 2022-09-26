# frozen_string_literal: true

class Calendar < ApplicationRecord
  belongs_to :season
  has_many :days, inverse_of: :calendar

  validates :name, :season, presence: true
end
