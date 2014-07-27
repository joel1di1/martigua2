class TrainingInvitation < ActiveRecord::Base
  belongs_to :training

  validates_presence_of :training

  after_create :send_invitations_for_undecided_users!

  def send_invitations_for_undecided_users!
    training.sections.map do |section| 
      section.players.each do |user| 
        availability = user.training_availabilities.where(training: training).take
        if availability.try(:available).nil?
          UserMailer.send_training_invitation(training, user).deliver
        end
      end 
    end
  end
  handle_asynchronously :send_invitations_for_undecided_users!
end
