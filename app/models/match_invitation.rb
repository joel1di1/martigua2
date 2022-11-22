# frozen_string_literal: true

class MatchInvitation < ApplicationRecord
  belongs_to :match
  belongs_to :user, optional: true

  after_create :async_send_invitations_for_undecided_players!

  def send_invitations_for_undecided_players!
    match.availability_not_set.each do |user|
      next_weekend_matches = user.next_weekend_matches
      UserMailer.send_match_invitation(next_weekend_matches.to_a, user).deliver_later unless next_weekend_matches.empty?
    end
  end
end
