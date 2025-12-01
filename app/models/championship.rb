# frozen_string_literal: true

class Championship < ApplicationRecord # rubocop:disable Metrics/ClassLength
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

    # Add new matches if any
    new_matches_added = sync_new_matches!

    # Reload matches if new ones were added
    matches.reload if new_matches_added

    matches.each do |match|
      match.ffhb_sync!
    rescue FfhbServiceError => e
      Sentry.capture_exception(e)
      Rails.logger.debug { "Error while syncing match #{match.id}: #{e.message}" }
    end

    _, _, championship_id, phase_id, pool_id = ffhb_key.split
    stats_sync!(championship_id, phase_id, pool_id)
  end

  def stats_sync!(championship_id, phase_id, pool_id)
    stats_json = FfhbService.instance.fetch_competition_stats(championship_id, phase_id, pool_id)

    stats = stats_json['rowsData'].map do |stat_json|
      {
        championship_id: id,
        player_id: stat_json['individuId'],
        match_played: stat_json['matchCount'],
        goals: stat_json['totalButs'],
        saves: stat_json['totalArrets'],
        first_name: stat_json['prenom'],
        last_name: stat_json['nom'],
        created_at: Time.zone.now,
        updated_at: Time.zone.now
      }
    end

    UserChampionshipStat.upsert_all(stats, unique_by: %i[championship_id player_id]) # rubocop:disable Rails/SkipsModelValidations
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

  delegate :find_or_create_day_for, to: :calendar

  private

  def sync_new_matches! # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    _, _, competition_key, _phase_id, pool_id = ffhb_key.split
    return if competition_key.blank? || pool_id.blank?

    # Get pool details to access journees
    pool_details = FfhbService.instance.fetch_pool_details(competition_key, pool_id)
    journees = Oj.load(pool_details['selected_poule']['journees'])

    # Get existing match ffhb_keys for quick lookup
    existing_ffhb_keys = matches.pluck(:ffhb_key).to_set

    # Map enrolled teams by their FFHB team ID for quick lookup
    enrolled_teams_by_ffhb_id = enrolled_team_championships.index_by(&:ffhb_team_id)

    # Only consider teams that have sections (i.e., real teams that belong to a club/section)
    # Teams without sections are temporary teams created during championship import
    teams_with_sections = enrolled_team_championships.select { |etc| etc.team.team_sections.exists? }
    return false if teams_with_sections.empty? # No real teams, nothing to sync

    team_ids = teams_with_sections.map(&:ffhb_team_id)

    new_matches = []

    journees.each do |journee|
      journee_details = FfhbService.instance.fetch_journee_details(competition_key, pool_id, journee['journee_numero'])

      journee_details['rencontres'].each do |match_data|
        # Only process matches involving our teams
        next unless team_ids.intersect?([match_data['equipe1Id'], match_data['equipe2Id']])

        # Build the ffhb_key for this match
        match_ffhb_key = "#{competition_key} #{pool_id} #{match_data['ext_rencontreId']}"

        # Skip if match already exists
        next if existing_ffhb_keys.include?(match_ffhb_key)

        # Find the enrolled teams
        local_enrolled = enrolled_teams_by_ffhb_id[match_data['equipe1Id']]
        visitor_enrolled = enrolled_teams_by_ffhb_id[match_data['equipe2Id']]

        next if local_enrolled.blank? || visitor_enrolled.blank?

        # Find or create the day for this match
        period_start_date = Date.parse(journee['date_debut'])
        period_end_date = Date.parse(journee['date_fin'])
        day_name = "WE du #{I18n.l(period_start_date, format: :short)} au #{I18n.l(period_end_date, format: :short)}"
        day = find_or_create_day_for_match(day_name, period_start_date.beginning_of_week, period_end_date)

        # Create the new match
        new_matches << Match.new(
          local_team: local_enrolled.team,
          visitor_team: visitor_enrolled.team,
          day:,
          ffhb_key: match_ffhb_key,
          championship: self
        )
      end
    end

    # Save all new matches
    if new_matches.any?
      new_matches.each(&:save!)
      Rails.logger.info { "Added #{new_matches.size} new matches to championship #{id}" }
      true
    else
      false
    end
  rescue FfhbServiceError => e
    Sentry.capture_exception(e)
    Rails.logger.debug { "Error while syncing new matches for championship #{id}: #{e.message}" }
    false
  end

  def find_or_create_day_for_match(day_name, period_start_date, period_end_date)
    day = calendar.days.find_by(name: day_name)
    if day.blank?
      day = Day.new(name: day_name, period_start_date:, period_end_date:)
      calendar.days << day
      calendar.save!
    end
    day
  end

  def find_match_by_team_names(event_team_names)
    match_teams =
      event_team_names.map do |team_name|
        enrolled_team_championships.find { |enrolled_team| enrolled_team.enrolled_name == team_name }
      end.map(&:team)

    matches.find { |match| match.local_team == match_teams.first && match.visitor_team == match_teams.second }
  end
end
