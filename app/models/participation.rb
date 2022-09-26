# frozen_string_literal: true

class Participation < ApplicationRecord
  PLAYER = 'player'
  COACH = 'coach'

  ALL_ROLES = [COACH, PLAYER].freeze

  belongs_to :user, inverse_of: :participations
  belongs_to :section, inverse_of: :participations
  belongs_to :season, inverse_of: :participations

  validates :role, :user, :season, :section, presence: true

  scope :coachs, -> { where(role: COACH) }

  def renew!
    Participation.create!(user:, section:, role:, season: Season.current)
  end
end
