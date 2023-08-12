# frozen_string_literal: true

class Championship < ApplicationRecord
  belongs_to :season
  belongs_to :calendar
  has_many :burns, dependent: :destroy
  has_many :burned_players, through: :burns, source: :user
  has_many :enrolled_team_championships, inverse_of: :championship, dependent: :destroy
  has_many :teams, through: :enrolled_team_championships
  has_many :matches, inverse_of: :championship, dependent: :destroy
  has_many :user_championship_stats, inverse_of: :championship, dependent: :destroy
  has_many :championship_group_championships, dependent: :destroy
  has_many :championship_groups, through: :championship_group_championships

  validates :name, presence: true

  scope :of_current_season, -> { where(season: Season.current) }

  after_initialize :init

  def self.create_from_ffhb!(type_competition:, code_comite:, code_competition:, phase_id:, code_pool:, team_links:, linked_calendar: nil) # rubocop:disable Metrics/ParameterLists
    championship =
      FfhbService.instance.build_championship(type_competition:, code_comite: code_comite.to_i, code_competition:,
                                              phase_id:, code_pool:, team_links:, linked_calendar:)

    championship.save!
    championship
  end

  def ffhb_sync!
    return if ffhb_key.blank?

    matches.each(&:ffhb_sync!)
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

  def burn!(user)
    burns.find_or_create_by(user:)
  end

  def unburn!(user)
    burns.where(user:).delete_all
  end

  def burned?(user)
    burned_players.include?(user)
  end

  def freeze!(user)
    championship_groups.map { |championship_group| championship_group.freeze!(user, championship: self) }
  end

  private

  def find_match_by_team_names(event_team_names)
    match_teams =
      event_team_names.map do |team_name|
        enrolled_team_championships.find { |enrolled_team| enrolled_team.enrolled_name == team_name }
      end.map(&:team)

    matches.find { |match| match.local_team == match_teams.first && match.visitor_team == match_teams.second }
  end
end
