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

    availabilities_by_match = MatchAvailability
                              .where(match_id: match_ids, user_id: section_player_ids)
                              .pluck(:match_id, :user_id, :available)
                              .group_by(&:first)

    absences = section_player_absences(section_player_ids)

    @match_availability_counts = build_availability_counts_hash(
      availabilities_by_match,
      absences,
      section_player_ids.size
    )
  end

  def section_player_absences(section_player_ids)
    return [] if section_player_ids.empty?

    min_match_time = @next_matches.map { |m| m.start_datetime || m.day&.period_start_date }.compact.min
    max_match_time = @next_matches.map { |m| m.start_datetime || m.day&.period_end_date }.compact.max
    return [] if min_match_time.blank? || max_match_time.blank?

    fetch_absences_for_period(min_match_time, max_match_time).to_a
  end

  def fetch_absences_for_period(min_match_time, max_match_time)
    Participation
      .joins(user: :absences)
      .where(section: @section, season: Season.current, role: Participation::PLAYER)
      .where('absences.start_at <= ? AND absences.end_at >= ?', max_match_time, min_match_time)
      .select('DISTINCT participations.user_id, absences.start_at, absences.end_at')
  end

  def absences_covering(absences, match)
    start_time = match.start_datetime || match.day&.period_start_date
    end_time = match.end_datetime || match.day&.period_end_date
    return [] if start_time.blank? || end_time.blank?

    absences.select { |absence| absence.start_at <= start_time && absence.end_at >= end_time }
  end

  def build_availability_counts_hash(availabilities_by_match, absences, total_players)
    counts_hash = {}
    @next_matches.each do |match|
      rows = availabilities_by_match[match.id] || []
      available_user_ids = rows.filter_map { |_match_id, user_id, available| user_id if available }
      not_available_count = rows.count { |_match_id, _user_id, available| available == false }

      match_absences = absences_covering(absences, match)

      # Only subtract absences from available count if they were marked available
      # The away players who are already marked not_available or have no response shouldn't be double-counted
      away_from_available = match_absences.count { |absence| available_user_ids.include?(absence.user_id) }

      counts_hash[match.id] = {
        available: [available_user_ids.size - away_from_available, 0].max,
        not_available: not_available_count + match_absences.size,
        no_response: total_players - available_user_ids.size - not_available_count
      }
    end
    counts_hash
  end
end
