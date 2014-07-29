require 'rails_helper'

RSpec.describe TrainingInvitation, :type => :model do
  it { should validate_presence_of :training }

  describe '#send_invitations_for_undecided_users' do

    around(:each) do |example|
      Delayed::Worker.delay_jobs = false
      example.run
      Delayed::Worker.delay_jobs = true
    end

    let(:section) { create :section }
    let(:other_section) { create :section }

    let!(:player_undecided_1) { create :user, with_section: section }
    let!(:player_undecided_2) { create :user, with_section: section }
    let!(:player_already_answered) { create :user, with_section: section }
    let!(:player_already_answered_with_nil) { create :user, with_section: section }
    let!(:training_presence) { create :training_presence, user: player_already_answered, training: training, present: [true, false].sample }
    let!(:training_presence_2) { create :training_presence, user: player_already_answered_with_nil, training: training, present: nil }
    let!(:coach_undecided) { create :user, with_section_as_coach: section }
    let!(:player_in_other_section) { create :user, with_section: other_section }

    let(:training) { create :training, with_section: section }

    it 'should send mails to undecided users' do
      expect{create :training_invitation, training: training}.to change{ ActionMailer::Base.deliveries.count }.by(3)
    end
  end
end
