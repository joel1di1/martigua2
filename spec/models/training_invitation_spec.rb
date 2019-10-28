# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TrainingInvitation, :type => :model do
  it { should validate_presence_of :training }

  describe '#send_invitations_for_undecided_users' do
    let(:section) { create :section }
    let(:group) { create :group, section: section }

    let!(:player_undecided_1) { create :user, with_section: section, with_group: group }
    let!(:player_undecided_2) { create :user, with_section: section, with_group: group }
    let!(:player_already_answered) { create :user, with_section: section, with_group: group }
    let!(:player_already_answered_with_nil) { create :user, with_section: section, with_group: group }
    let!(:training_presence) { create :training_presence, user: player_already_answered, training: training, is_present: [true, false].sample }
    let!(:training_presence_2) { create :training_presence, user: player_already_answered_with_nil, training: training, is_present: nil }
    let!(:coach_undecided) { create :user, with_section_as_coach: section }
    let!(:player_not_in_group) { create :user, with_section: section }

    let(:training) { create :training, with_section: section, with_group: group }

    it 'sends mails to undecided users' do
      expect { create :training_invitation, training: training }.to change { ActionMailer::Base.deliveries.count }.by(3)
    end
  end
end
