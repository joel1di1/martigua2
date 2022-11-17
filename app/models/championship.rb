# frozen_string_literal: true

class Championship < ApplicationRecord
  belongs_to :season
  belongs_to :calendar
  has_many :burns, dependent: :destroy
  has_many :burned_players, through: :burns, source: :user
  has_many :enrolled_team_championships, inverse_of: :championship, dependent: :destroy
  has_many :teams, through: :enrolled_team_championships
  has_many :matches, inverse_of: :championship, dependent: :destroy

  validates :name, presence: true

  scope :of_current_season, -> { where(season: Season.current) }

  after_initialize :init

  def self.create_from_ffhb!(code_pool:, code_division:, code_comite:, type_competition:, team_links:, linked_calendar: nil)
    championship =
      FfhbService.instance.build_championship(code_pool:, code_division:, code_comite:, type_competition:, team_links:, linked_calendar:)

    championship.save!
    championship
  end

  def ffhb_sync!
    return if ffhb_key.blank?

    enrolled_team_names = enrolled_team_championships.pluck(:enrolled_name)

    pool_as_json = FfhbService.instance.get_pool_as_json(ffhb_key[/[^-]+$/])
    pool_as_json['dates'].each do |_index, date|
      date['events'].each do |event|
        event_team_names = event['teams'].pluck('name')
        next if event_team_names.intersection(enrolled_team_names).blank?

        match = find_match_by_team_names(event_team_names)

        next if match.blank?

        match.update_with_ffhb_event!(event)
      end
    end

    self
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

  private

  def find_match_by_team_names(event_team_names)
    match_teams =
      event_team_names.map do |team_name|
        enrolled_team_championships.find { |enrolled_team| enrolled_team.enrolled_name == team_name }
      end.map(&:team)

    matches.find { |match| match.local_team == match_teams.first && match.visitor_team == match_teams.second }
  end
end
