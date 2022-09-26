# frozen_string_literal: true

class MatchSelection < ApplicationRecord
  belongs_to :match
  belongs_to :team
  belongs_to :user
end
