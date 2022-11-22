# frozen_string_literal: true

class TrainingInvitation < ApplicationRecord
  belongs_to :training

  after_create :async_send_invitations_for_undecided_users!

  def send_invitations_for_undecided_users!
    training.presence_not_set.each do |user|
      UserMailer.send_training_invitation(training, user).deliver_later
    end
  end
end
