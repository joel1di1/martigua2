class TrainingInvitation < ActiveRecord::Base
  belongs_to :training

  validates_presence_of :training

  after_create :send_invitations_for_undecided_users!

  def send_invitations_for_undecided_users!
    training.sections.map do |section| 
      section.players.each do |user| 
        presence = user.training_presences.where(training: training).take
        if presence.try(:present).nil?
          UserMailer.send_training_invitation(training, user).deliver
        end
      end 
    end
  end
  handle_asynchronously :send_invitations_for_undecided_users!
end
