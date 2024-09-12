# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Absence do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_inclusion_of(:name).in_array(%w[Blessure Maladie Perso Travail Autre]) }

  describe '#update_training_presences' do
    let(:user) { create(:user) }
    let(:training) { create(:training) }

    context 'when user declared nothing' do
      describe 'on create' do
        it 'updates the training presences' do
          expect(user.present_for?(training)).to be_nil
          create(:absence, user:, start_at: training.start_datetime - 1.day, end_at: training.start_datetime + 2.days)
          expect(user.present_for?(training)).to be false
        end
      end

      describe 'on update' do
        it 'updates the training presences' do
          expect(user.present_for?(training)).to be_nil
          absence = create(:absence, user:, start_at: training.start_datetime - 10.days, end_at: training.start_datetime - 2.days)
          expect(user.present_for?(training)).to be_nil
          absence.update(end_at: training.start_datetime + 2.days)
          expect(user.present_for?(training)).to be false

          # absence.update(end_at: training.start_datetime - 2.days)
          # expect(user.present_for?(training)).to be_nil
        end
      end
    end

    context 'when user declared present' do
      before { user.present_for!(training) }

      describe 'on create' do
        it 'updates the training presences' do
          expect(user.present_for?(training)).to be true
          create(:absence, user:, start_at: training.start_datetime - 1.day, end_at: training.start_datetime + 2.days)
          expect(user.present_for?(training)).to be false
        end
      end

      describe 'on update' do
        it 'updates the training presences' do
          expect(user.present_for?(training)).to be true
          absence = create(:absence, user:, start_at: training.start_datetime - 10.days, end_at: training.start_datetime - 2.days)
          expect(user.present_for?(training)).to be true
          absence.update(end_at: training.start_datetime + 2.days)
          expect(user.present_for?(training)).to be false

          # absence.update(end_at: training.start_datetime - 2.days)
          # expect(user.present_for?(training)).to be_nil
        end
      end
    end
  end

  describe '#update_match_availabilities' do
    let(:user) { create(:user) }
    let(:match) { create(:match) }

    context 'when user declared nothing' do
      describe 'on create' do
        it 'updates the match availabilities' do
          expect(user.is_available_for?(match)).to be_nil
          create(:absence, user:, start_at: match.start_datetime - 1.day, end_at: match.start_datetime + 2.days)
          expect(user.reload.is_available_for?(match)).to be false
        end
      end

      describe 'on update' do
        it 'updates the match availabilities' do
          expect(user.is_available_for?(match)).to be_nil
          absence = create(:absence, user:, start_at: match.start_datetime - 10.days, end_at: match.start_datetime - 2.days)
          expect(user.reload.is_available_for?(match)).to be_nil
          absence.update(end_at: match.start_datetime + 2.days)
          expect(user.reload.is_available_for?(match)).to be false

          # absence.update(end_at: match.start_datetime - 2.days)
          # expect(user.reload.is_available_for?(match)).to be_nil
        end
      end
    end

    context 'when user declared present' do
      before { create(:match_availability, user:, match:, available: true) }

      describe 'on create' do
        it 'updates the match availabilities' do
          expect(user.is_available_for?(match)).to be true
          create(:absence, user:, start_at: match.start_datetime - 1.day, end_at: match.start_datetime + 2.days)
          expect(user.reload.is_available_for?(match)).to be false
        end
      end

      describe 'on update' do
        it 'updates the match availabilities' do
          expect(user.is_available_for?(match)).to be true
          absence = create(:absence, user:, start_at: match.start_datetime - 10.days, end_at: match.start_datetime - 2.days)
          expect(user.reload.is_available_for?(match)).to be true
          absence.update(end_at: match.start_datetime + 2.days)
          expect(user.reload.is_available_for?(match)).to be false

          # absence.update(end_at: match.start_datetime - 2.days)
          # expect(user.reload.is_available_for?(match)).to be_nil
        end
      end
    end
  end
end
