# frozen_string_literal: true

class Participation < ActiveRecord::Base
  PLAYER = 'player'
  COACH = 'coach'

  ALL_ROLES = [COACH, PLAYER].freeze

  belongs_to :user, inverse_of: :participations
  belongs_to :section, inverse_of: :participations
  belongs_to :season, inverse_of: :participations

  validates_presence_of :user
  validates_presence_of :season
  validates_presence_of :section
  validates_presence_of :role

  scope :coachs, -> { where(role: COACH) }

  def renew!
    Participation.create!(user: user, section: section, role: role, season: Season.current)
  end
end
