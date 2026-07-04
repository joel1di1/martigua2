# frozen_string_literal: true

module Ffhb
  # Syncs a championship with the FFHB: adds newly scheduled matches,
  # refreshes every match (date, score, location), then player stats.
  class ChampionshipSync
    def initialize(championship)
      @championship = championship
    end

    def call
      return if championship.ffhb_key.blank?

      new_matches_added = sync_new_matches!
      championship.matches.reload if new_matches_added

      sync_matches!
      sync_player_stats!
      sync_championship_stats!
    end

    # Upserts the per-player championship stats (goals, saves…) from the FFHB.
    def sync_championship_stats!
      _, _, competition_key, phase_id, pool_id = championship.ffhb_key.split
      stats_json = FfhbService.instance.fetch_competition_stats(competition_key, phase_id, pool_id)

      stats = stats_json['rowsData'].map do |stat_json|
        {
          championship_id: championship.id,
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

    private

    attr_reader :championship

    def sync_matches!
      championship.matches.each do |match|
        match.ffhb_sync!
      rescue FfhbServiceError => e
        Sentry.capture_exception(e)
        Rails.logger.debug { "Error while syncing match #{match.id}: #{e.message}" }
      end
    end

    def sync_player_stats!
      championship.matches.select { |m| m.local_score.present? && m.fdm_code.present? }.each do |match|
        match.sync_player_stats!
      rescue StandardError => e
        Sentry.capture_exception(e)
        Rails.logger.debug { "Error syncing player stats for match #{match.id}: #{e.message}" }
      end
    end

    def sync_new_matches!
      _, _, competition_key, _phase_id, pool_id = championship.ffhb_key.split
      return false if competition_key.blank? || pool_id.blank?

      # Only consider teams that have sections (i.e., real teams that belong to a club/section)
      # Teams without sections are temporary teams created during championship import
      linked_enrollments = championship.enrolled_team_championships.select { |etc| etc.team.team_sections.exists? }
      return false if linked_enrollments.empty?

      new_matches = build_new_matches(competition_key, pool_id, linked_enrollments)
      return false if new_matches.empty?

      new_matches.each(&:save!)
      Rails.logger.info { "Added #{new_matches.size} new matches to championship #{championship.id}" }
      true
    rescue FfhbServiceError => e
      Sentry.capture_exception(e)
      Rails.logger.debug { "Error while syncing new matches for championship #{championship.id}: #{e.message}" }
      false
    end

    def build_new_matches(competition_key, pool_id, linked_enrollments)
      pool_details = FfhbService.instance.fetch_pool_details(competition_key, pool_id)
      journees = Oj.load(pool_details['selected_poule']['journees'])

      existing_ffhb_keys = championship.matches.pluck(:ffhb_key).to_set
      enrollments_by_ffhb_id = championship.enrolled_team_championships.index_by(&:ffhb_team_id)
      linked_team_ids = linked_enrollments.map(&:ffhb_team_id)

      journees.flat_map do |journee|
        journee_details = FfhbService.instance.fetch_journee_details(competition_key, pool_id,
                                                                     journee['journee_numero'])

        journee_details['rencontres'].filter_map do |match_data|
          build_match(match_data, journee, competition_key, pool_id,
                      existing_ffhb_keys:, enrollments_by_ffhb_id:, linked_team_ids:)
        end
      end
    end

    def build_match(match_data, journee, competition_key, pool_id, existing_ffhb_keys:, enrollments_by_ffhb_id:, linked_team_ids:) # rubocop:disable Metrics/ParameterLists
      # Only process matches involving our teams
      return unless linked_team_ids.intersect?([match_data['equipe1Id'], match_data['equipe2Id']])

      match_ffhb_key = "#{competition_key} #{pool_id} #{match_data['ext_rencontreId']}"
      return if existing_ffhb_keys.include?(match_ffhb_key)

      local_enrolled = enrollments_by_ffhb_id[match_data['equipe1Id']]
      visitor_enrolled = enrollments_by_ffhb_id[match_data['equipe2Id']]
      return if local_enrolled.blank? || visitor_enrolled.blank?

      Match.new(
        local_team: local_enrolled.team,
        visitor_team: visitor_enrolled.team,
        day: day_for(journee),
        ffhb_key: match_ffhb_key,
        championship:
      )
    end

    def day_for(journee)
      period_start_date = Date.parse(journee['date_debut'])
      period_end_date = Date.parse(journee['date_fin'])
      day_name = "WE du #{I18n.l(period_start_date, format: :short)} au #{I18n.l(period_end_date, format: :short)}"

      calendar = championship.calendar
      day = calendar.days.find_by(name: day_name)
      if day.blank?
        day = Day.new(name: day_name, period_start_date: period_start_date.beginning_of_week,
                      period_end_date:)
        calendar.days << day
        calendar.save!
      end
      day
    end
  end
end
