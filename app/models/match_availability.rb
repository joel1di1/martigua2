# frozen_string_literal: true

class MatchAvailability < ApplicationRecord
  belongs_to :match
  belongs_to :user
end
