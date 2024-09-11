# frozen_string_literal: true

class MatchInvitation < ApplicationRecord
  belongs_to :match
  belongs_to :user, optional: true

  after_create :async_send_invitations_for_undecided_players!

  def send_invitations_for_undecided_players!
    match.availability_not_set.each do |user|
      next_7_days_matches = user.next_7_days_matches
      UserMailer.send_match_invitation(next_7_days_matches.to_a, user).deliver_later unless next_7_days_matches.empty?
    end
  end
end
