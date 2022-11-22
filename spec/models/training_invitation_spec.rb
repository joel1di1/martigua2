# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TrainingInvitation do
  it { is_expected.to belong_to :training }

  describe '#send_invitations_for_undecided_users' do
    let(:section) { create(:section) }
    let(:group) { create(:group, section:) }

    let!(:player_undecided1) { create(:user, with_section: section, with_group: group) }
    let!(:player_undecided2) { create(:user, with_section: section, with_group: group) }
    let!(:player_already_answered) { create(:user, with_section: section, with_group: group) }
    let!(:player_already_answered_with_nil) { create(:user, with_section: section, with_group: group) }
    let!(:training_presence) do
      create(:training_presence, user: player_already_answered, training:, is_present: [true, false].sample)
    end
    let!(:training_presence2) do
      create(:training_presence, user: player_already_answered_with_nil, training:, is_present: nil)
    end
    let!(:coach_undecided) { create(:user, with_section_as_coach: section) }
    let!(:player_not_in_group) { create(:user, with_section: section) }

    let(:training) { create(:training, with_section: section, with_group: group) }

    it 'sends mails to undecided users' do
      Sidekiq::Testing.inline! do
        expect { create(:training_invitation, training:) }.to change { ActionMailer::Base.deliveries.count }.by(3)
      end
    end
  end
end
