# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Season do
  let(:season) { create(:season) }

  it { is_expected.to have_many :participations }
  it { is_expected.to have_many :calendars }
  it { is_expected.to have_many :championships }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :start_date }
  it { is_expected.to validate_presence_of :end_date }

  describe '.current' do
    before { Season.destroy_all }

    context 'with only one season' do
      subject { Season.current }

      let!(:only_season) { create(:season, start_date: Time.zone.today - 1.month) }

      it { is_expected.to eq only_season }
    end

    context 'with one old season' do
      let(:today) { Time.zone.today }
      let!(:first_season) { create(:season, start_date: Date.new(2001, 9, 1)) }

      it { expect(Season.current.start_date).to be < today }
      it { expect(Season.current.end_date).to be >= today }
    end

    context 'with no season' do
      subject { Season.current }

      it { is_expected.not_to be_nil }
    end
  end

  describe '#to_s' do
    it { expect(season.to_s).to eq "#{season.start_date.year}-#{season.end_date.year}" }
  end

  describe '#previous' do
    subject { Season.current.previous }

    it { expect(subject.start_date).to eq(Season.current.start_date - 1.year) }

    context 'with gaps in IDs' do
      before do
        Season.destroy_all
        middle_season = create(:season, start_date: Date.new(2021, 9, 1), end_date: Date.new(2022, 8, 31))
        middle_season.destroy
      end

      let!(:first_season) { create(:season, start_date: Date.new(2020, 9, 1), end_date: Date.new(2021, 8, 31)) }
      let!(:third_season) { create(:season, start_date: Date.new(2022, 9, 1), end_date: Date.new(2023, 8, 31)) }

      # Create a season with ID gap by deleting the middle one

      it 'finds the previous season despite ID gaps' do
        expect(third_season.previous).to eq(first_season)
      end

      it 'returns nil when there is no previous season' do
        expect(first_season.previous).to be_nil
      end
    end
  end

  describe 'coach renewal on season creation' do
    # Freeze time to ensure consistent test behavior
    around do |example|
      Timecop.freeze(Date.new(2024, 9, 15)) do
        example.run
      end
    end

    let(:old_season) { create(:season, start_date: Date.new(2023, 9, 1), end_date: Date.new(2024, 8, 31)) }
    let(:section) { create(:section) }
    let(:other_section) { create(:section) }
    let(:coach1) { create(:user) }
    let(:coach2) { create(:user) }
    let(:multi_section_coach) { create(:user) }
    let(:player) { create(:user) }

    before do
      # Create participations in the old season
      create(:participation, user: coach1, section:, season: old_season, role: Participation::COACH)
      create(:participation, user: coach2, section:, season: old_season, role: Participation::COACH)
      create(:participation, user: multi_section_coach, section:, season: old_season, role: Participation::COACH)
      create(:participation, user: multi_section_coach, section: other_section, season: old_season,
                             role: Participation::COACH)
      create(:participation, user: player, section:, season: old_season, role: Participation::PLAYER)
    end

    context 'when a new season is created' do
      let!(:new_season) do
        Season.create!(
          start_date: Date.new(2024, 9, 1),
          end_date: Date.new(2025, 8, 31),
          name: '2024-2025'
        )
      end

      it 'automatically renews coach participations from previous season' do
        expect(new_season.participations.where(role: Participation::COACH).count).to eq(4)
      end

      it 'renews correct coaches' do
        coach_users = new_season.participations.where(role: Participation::COACH).map(&:user).uniq
        expect(coach_users).to contain_exactly(coach1, coach2, multi_section_coach)
      end

      it 'does not automatically renew player participations' do
        expect(new_season.participations.where(role: Participation::PLAYER).count).to eq(0)
      end

      it 'coaches can access their section in new season' do
        expect(section.coachs(season: new_season)).to contain_exactly(coach1, coach2, multi_section_coach)
      end

      it 'renews multi-section coaches for all their sections' do
        expect(new_season.participations.where(user: multi_section_coach, role: Participation::COACH).count).to eq(2)
        expect(section.coachs(season: new_season)).to include(multi_section_coach)
        expect(other_section.coachs(season: new_season)).to include(multi_section_coach)
      end

      it 'renews both coach and player roles when a user has both' do
        # Add a user who is both coach and player in the new season's previous season
        coach_player = create(:user)
        create(:participation, user: coach_player, section:, season: new_season.previous, role: Participation::COACH)
        create(:participation, user: coach_player, section:, season: new_season.previous, role: Participation::PLAYER)

        # Trigger renewal again to pick up the coach-player we just added
        new_season.send(:renew_coaches_from_previous_season)

        # Both coach and player roles should be renewed
        expect(new_season.participations.where(user: coach_player, role: Participation::COACH).count).to eq(1)
        expect(new_season.participations.where(user: coach_player, role: Participation::PLAYER).count).to eq(1)
      end

      it 'does not create duplicate coach participations when renewal is triggered multiple times' do
        # Count existing participations for coach1
        initial_count = new_season.participations.where(role: Participation::COACH, user: coach1).count
        expect(initial_count).to eq(1)

        # Trigger renewal again by calling the private method directly
        new_season.send(:renew_coaches_from_previous_season)

        # Should still have only one participation for coach1 in the new season
        final_count = new_season.participations.where(role: Participation::COACH, user: coach1).count
        expect(final_count).to eq(1)
      end
    end

    context 'when there is no previous season' do
      before { Season.destroy_all }

      let!(:first_season) do
        Season.create!(
          start_date: Date.new(2024, 9, 1),
          end_date: Date.new(2025, 8, 31),
          name: '2024-2025'
        )
      end

      it 'does not create any participations' do
        expect(first_season.participations.count).to eq(0)
      end
    end
  end
end
