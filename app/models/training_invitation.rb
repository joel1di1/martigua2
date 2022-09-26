# frozen_string_literal: true

class TrainingInvitation < ApplicationRecord
  belongs_to :training

  after_create :send_invitations_for_undecided_users!

  validates :training, presence: true

  def send_invitations_for_undecided_users!
    training.presence_not_set.each do |user|
      UserMailer.send_training_invitation(training, user).deliver_now
    end
  end
  handle_asynchronously :send_invitations_for_undecided_users!
end
