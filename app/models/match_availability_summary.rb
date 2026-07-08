# frozen_string_literal: true

# Single source of truth for "who is available / not available / without
# response" for a match, given already-fetched data. Used by Match for
# single-match reads and by PrefetchMatchData for bulk computation, so both
# always agree:
# - a player marked available but away counts as not available
# - away players are never double-counted in not_available
# - away players without a response are not counted in no_response
class MatchAvailabilitySummary
  # player_ids: population used for the no-response count
  # availability_rows: [user_id, available] pairs from match_availabilities
  # away_user_ids: users with an absence covering the match window
  def initialize(player_ids:, availability_rows:, away_user_ids:)
    @player_ids = player_ids
    @availability_by_user_id = availability_rows.to_h
    @away_user_ids = away_user_ids.uniq
  end

  def available_user_ids
    @available_user_ids ||= marked_user_ids(true) - @away_user_ids
  end

  def not_available_user_ids
    @not_available_user_ids ||= (marked_user_ids(false) + @away_user_ids).uniq
  end

  def no_response_user_ids
    @no_response_user_ids ||= @player_ids - available_user_ids - not_available_user_ids
  end

  def counts
    {
      available: available_user_ids.size,
      not_available: not_available_user_ids.size,
      no_response: no_response_user_ids.size
    }
  end

  private

  def marked_user_ids(value)
    @availability_by_user_id.filter_map { |user_id, available| user_id if available == value }
  end
end
