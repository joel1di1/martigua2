# frozen_string_literal: true

class Participation < ApplicationRecord
  PLAYER = 'player'
  COACH = 'coach'

  ALL_ROLES = [COACH, PLAYER].freeze

  POSITIONS = %w[goalkeeper left_wing right_wing left_back right_back center_back pivot].freeze

  belongs_to :user, inverse_of: :participations
  belongs_to :section, inverse_of: :participations
  belongs_to :season, inverse_of: :participations

  validates :role, presence: true
  validates :main_position, inclusion: { in: POSITIONS }, allow_nil: true

  scope :coachs, -> { where(role: COACH) }

  def renew!
    Participation.create!(user:, section:, role:, season: Season.current)
  end
end
