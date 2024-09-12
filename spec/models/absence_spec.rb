# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Absence do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_inclusion_of(:name).in_array(%w[Blessure Maladie Perso Travail Autre]) }

  describe '#update_training_presences' do
    let(:user) { create(:user) }
    let(:training) { create(:training) }

    before { user.present_for!(training) }

    it 'updates the training presences' do
      expect(user.present_for?(training)).to be true
      create(:absence, user:, start_at: training.start_datetime - 1.day, end_at: training.start_datetime + 2.days)
      expect(user.present_for?(training)).to be false
    end
  end

  describe '#update_match_availabilities' do
    let(:user) { create(:user) }
    let(:match) { create(:match) }

    before { create(:match_availability, user:, match:, available: true) }

    it 'updates the match availabilities' do
      expect(user.is_available_for?(match)).to be true
      create(:absence, user:, start_at: match.start_datetime - 1.day, end_at: match.start_datetime + 2.days)
      expect(user.reload.is_available_for?(match)).to be false
    end
  end
end
