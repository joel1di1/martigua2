# frozen_string_literal: true

class Calendar < ApplicationRecord
  belongs_to :season
  has_many :days, inverse_of: :calendar, dependent: :destroy

  validates :name, presence: true
end
