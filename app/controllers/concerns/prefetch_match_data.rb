# frozen_string_literal: true

module PrefetchMatchData
  extend ActiveSupport::Concern

  private

  def preload_match_data
    @current_user_is_player = current_user.player_of?(@section)
    preload_current_user_availabilities
    precompute_match_availability_counts
  end

  def preload_current_user_availabilities
    match_ids = @next_matches.map(&:id)
    @current_user_availabilities = MatchAvailability.where(
      user: current_user,
      match_id: match_ids
    ).index_by(&:match_id)
  end

  def precompute_match_availability_counts
    match_ids = @next_matches.map(&:id)
    section_player_ids = @section.players.pluck(:id)

    availability_rows_by_match = MatchAvailability
                                 .where(match_id: match_ids, user_id: section_player_ids)
                                 .pluck(:match_id, :user_id, :available)
                                 .group_by(&:first)

    absences = section_player_absences(section_player_ids)

    @match_availability_counts = {}
    @next_matches.each do |match|
      rows = (availability_rows_by_match[match.id] || []).map { |_match_id, user_id, available| [user_id, available] }
      away_user_ids = absences_covering(absences, match).map(&:user_id)

      @match_availability_counts[match.id] = MatchAvailabilitySummary.new(
        player_ids: section_player_ids,
        availability_rows: rows,
        away_user_ids:
      ).counts
    end
  end

  def section_player_absences(section_player_ids)
    return [] if section_player_ids.empty?

    min_match_time = @next_matches.filter_map(&:calculated_start_datetime).min
    max_match_time = @next_matches.filter_map { |m| m.end_datetime || m.day&.period_end_date }.max
    return [] if min_match_time.blank? || max_match_time.blank?

    fetch_absences_overlapping(min_match_time, max_match_time)
  end

  # All absences of the section's players that touch the [min, max] window;
  # per-match covering is then checked in memory with Absence#covers?.
  def fetch_absences_overlapping(min_match_time, max_match_time)
    Absence
      .joins(user: :participations)
      .where(participations: { section_id: @section.id, season: Season.current, role: Participation::PLAYER })
      .where(start_at: ..max_match_time)
      .where(end_at: min_match_time..)
      .select('DISTINCT absences.user_id, absences.start_at, absences.end_at')
      .to_a
  end

  def absences_covering(absences, match)
    start_time = match.calculated_start_datetime
    end_time = match.calculated_end_datetime
    return [] if start_time.blank? || end_time.blank?

    absences.select { |absence| absence.covers?(start_time, end_time) }
  end
end
