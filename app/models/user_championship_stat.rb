# frozen_string_literal: true

class UserChampionshipStat < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :championship

  after_save :burn_player_if_needed

  def full_name
    "#{first_name} #{last_name}"
  end

  # mark player as burned if he has played at least half of the championship matches plus one
  def burn_player_if_needed
    return if user.blank?
    return if match_played.blank?

    championship.freeze!(user) if match_played >= (championship.matches.size / 2) + 1
  end
end
