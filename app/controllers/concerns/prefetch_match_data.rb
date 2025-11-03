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

    availability_counts = MatchAvailability
                          .where(match_id: match_ids, user_id: section_player_ids)
                          .group(:match_id, :available)
                          .count

    absences_by_match = calculate_absences_by_match(section_player_ids)

    @match_availability_counts = build_availability_counts_hash(
      availability_counts,
      absences_by_match,
      section_player_ids.size
    )
  end

  def calculate_absences_by_match(section_player_ids)
    absences_by_match = Hash.new(0)
    return absences_by_match if section_player_ids.empty?

    min_match_time = @next_matches.map { |m| m.start_datetime || m.day&.period_start_date }.compact.min
    max_match_time = @next_matches.map { |m| m.start_datetime || m.day&.period_end_date }.compact.max
    return absences_by_match unless min_match_time && max_match_time

    absences = fetch_absences_for_period(min_match_time, max_match_time)
    match_absences_to_matches(absences, absences_by_match)

    absences_by_match
  end

  def fetch_absences_for_period(min_match_time, max_match_time)
    Participation
      .joins(user: :absences)
      .where(section: @section, season: Season.current, role: Participation::PLAYER)
      .where('absences.start_at < ? AND absences.end_at > ?', max_match_time, min_match_time)
      .select('DISTINCT participations.user_id, absences.start_at, absences.end_at')
  end

  def match_absences_to_matches(absences, absences_by_match)
    @next_matches.each do |match|
      start_time = match.start_datetime || match.day&.period_start_date
      end_time = match.start_datetime || match.day&.period_end_date
      next if start_time.blank? || end_time.blank?

      absences_by_match[match.id] = absences.count do |absence|
        absence.start_at < start_time && absence.end_at > end_time
      end
    end
  end

  def build_availability_counts_hash(availability_counts, absences_by_match, total_players)
    counts_hash = {}
    @next_matches.each do |match|
      available_count = availability_counts[[match.id, true]] || 0
      not_available_count = availability_counts[[match.id, false]] || 0
      away_count = absences_by_match[match.id] || 0

      actual_available = [available_count - away_count, 0].max
      actual_not_available = not_available_count + away_count
      no_response_count = total_players - available_count - not_available_count

      counts_hash[match.id] = {
        available: actual_available,
        not_available: actual_not_available,
        no_response: no_response_count
      }
    end
    counts_hash
  end
end
