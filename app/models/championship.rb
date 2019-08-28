# frozen_string_literal: true

class Championship < ActiveRecord::Base
  belongs_to :season
  belongs_to :calendar
  has_many :enrolled_team_championships, inverse_of: :championship, dependent: :destroy
  has_many :teams, through: :enrolled_team_championships
  has_many :matches, inverse_of: :championship, dependent: :destroy

  validates_presence_of :name
  validates_presence_of :season

  scope :of_current_season, -> { where(season: Season.current) }

  after_initialize :init

  def init
    self.season = Season.current
  end

  def enroll_team!(team)
    teams << team unless teams.include?(team)
    self
  end

  def unenroll_team!(team)
    teams.delete team if teams.include?(team)
    self
  end

  def enrolled_teams
    teams
  end
end
