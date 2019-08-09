# frozen_string_literal: true

class MatchAvailability < ActiveRecord::Base
  belongs_to :match
  belongs_to :user
end
