# frozen_string_literal: true

class Championship < ApplicationRecord
  belongs_to :season
  belongs_to :calendar
  has_many :enrolled_team_championships, inverse_of: :championship, dependent: :destroy
  has_many :teams, through: :enrolled_team_championships
  has_many :matches, inverse_of: :championship, dependent: :destroy

  validates :name, presence: true

  scope :of_current_season, -> { where(season: Season.current) }

  after_initialize :init

  def self.create_from_ffhb!(code_pool:, code_division:, code_comite:, type_competition:, team_links:)
    championship =
      FfhbService.instance.build_championship(code_pool:, code_division:, code_comite:, type_competition:, team_links:)

    championship.save!
    championship
  end

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
