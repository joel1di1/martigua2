# frozen_string_literal: true

class UserChampionshipStat < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :championship

  after_save :burn_player_if_needed

  def full_name
    "#{first_name} #{last_name}"
  end

  # mark player as burned if he has played at least half the matches across all sibling championships (phases)
  def burn_player_if_needed
    return if user.blank?
    return if match_played.blank?

    sibling_ids = championship.sibling_championship_ids
    total_played = UserChampionshipStat.where(user:, championship_id: sibling_ids).sum(:match_played)
    total_matches = Match.where(championship_id: sibling_ids).count
    championship.freeze!(user) if total_played >= (total_matches / 2.0)
  end
end
