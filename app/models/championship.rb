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
  scope :of_sections, lambda { |sections|
    joins(teams: :team_sections).where(team_sections: { section_id: sections }).distinct
  }

  after_initialize :init
  before_save :extract_competition_key

  def self.create_from_ffhb!(type_competition:, code_comite:, code_competition:, phase_id:, code_pool:, team_links:, linked_calendar: nil) # rubocop:disable Metrics/ParameterLists
    championship =
      FfhbService.instance.build_championship(type_competition:, code_comite: code_comite.to_i, code_competition:,
                                              phase_id:, code_pool:, team_links:, linked_calendar:)

    championship.save!
    championship
  end

  def ffhb_sync!
    Ffhb::ChampionshipSync.new(self).call
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
    burned_players.to_a.include?(user)
  end

  def freeze!(user)
    championship_groups.map { |championship_group| championship_group.freeze!(user, championship: self) }
  end

  def merge_calendar_from(other_championship)
    # Validations
    return { success: false, error: 'Cannot merge a championship with itself' } if self == other_championship

    if calendar_id == other_championship.calendar_id
      return { success: false,
               error: 'Championships already share the same calendar' }
    end
    if season_id != other_championship.season_id
      return { success: false,
               error: 'Cannot merge calendars from different seasons' }
    end

    source_calendar = other_championship.calendar
    target_calendar = calendar

    ApplicationRecord.transaction do
      # For each day in source calendar
      source_calendar.days.each do |source_day|
        # Normalize period dates to week boundaries
        normalized_start = source_day.period_start_date.beginning_of_week
        normalized_end = source_day.period_end_date.end_of_week

        # Try to find matching day in target calendar
        target_day = target_calendar.days.find do |day|
          day.period_start_date.beginning_of_week == normalized_start &&
            day.period_end_date.end_of_week == normalized_end
        end

        # If no matching day exists, create one
        if target_day.nil?
          target_day = target_calendar.days.create!(
            name: source_day.name,
            period_start_date: normalized_start,
            period_end_date: normalized_end
          )
        end

        # Reassign all matches from source day to target day
        source_day.matches.update_all(day_id: target_day.id) # rubocop:disable Rails/SkipsModelValidations
      end

      # Update the other championship to use our calendar
      other_championship.update!(calendar: target_calendar)

      # Delete the source calendar if no other championships reference it
      source_calendar.reload
      source_calendar.destroy! if Championship.where(calendar: source_calendar).none?
    end

    { success: true }
  rescue ActiveRecord::RecordInvalid => e
    { success: false, error: e.message }
  end

  def sibling_championship_ids
    return [id] if competition_key.blank?

    Championship.where(season:, competition_key:).pluck(:id)
  end

  delegate :find_or_create_day_for, to: :calendar

  private

  def extract_competition_key
    parts = ffhb_key.to_s.split
    self.competition_key = parts[2] if parts.size >= 3
  end

  def find_match_by_team_names(event_team_names)
    match_teams =
      event_team_names.map do |team_name|
        enrolled_team_championships.find { |enrolled_team| enrolled_team.enrolled_name == team_name }
      end.map(&:team)

    matches.find { |match| match.local_team == match_teams.first && match.visitor_team == match_teams.second }
  end
end
