# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Championship do
  let(:championship) { create(:championship) }
  let(:section) { create(:section) }
  let(:team) { create(:team, with_section: section) }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to belong_to :season }
  it { is_expected.to belong_to :calendar }
  it { is_expected.to have_many :teams }
  it { is_expected.to have_many :matches }
  it { is_expected.to have_many :burns }

  describe '.enroll_team!' do
    subject { championship.enroll_team!(team) }

    context 'with new team' do
      it { expect(subject.enrolled_teams).to contain_exactly(team) }
    end

    context 'with already enrolled team' do
      before { championship.enroll_team!(team) }

      it { expect(subject.enrolled_teams).to contain_exactly(team) }
    end
  end

  describe '#unenroll_team!' do
    subject { championship.unenroll_team!(team) }

    context 'with new team' do
      it { expect(subject.enrolled_teams).to be_empty }
    end

    context 'with already enrolled team' do
      before { championship.enroll_team!(team) }

      it { expect(subject.enrolled_teams).to be_empty }
    end
  end

  describe '.burned_players' do
    let(:section) { create(:section) }
    let!(:player1) { create(:user, with_section: section) }
    let!(:player2) { create(:user, with_section: section) }
    let!(:player3) { create(:user, with_section: section) }

    before do
      championship.burn!(player1)
      championship.burn!(player2)
      championship.burn!(player3)
      championship.unburn!(player2)
    end

    it { expect(championship.burned_players).to contain_exactly(player1, player3) }
  end

  describe '#find_or_create_day_for' do
    context 'with no existing day' do
      it 'creates a new day' do
        day = championship.find_or_create_day_for(Time.zone.parse('2023-09-16'))
        expect(day).to be_persisted
        expect(day.period_start_date).to eq(Date.parse('2023-09-11'))
        expect(day.period_end_date).to eq(Date.parse('2023-09-18'))
        expect(day.name).to eq('Week 2023-09-11 2023-09-17')
      end
    end
  end

  describe '#merge_calendar_from' do
    let(:season) { Season.current }
    let(:target_calendar) { create(:calendar, season:) }
    let(:source_calendar) { create(:calendar, season:) }
    let(:target_championship) { create(:championship, calendar: target_calendar, season:) }
    let(:source_championship) { create(:championship, calendar: source_calendar, season:) }

    context 'when merging with valid championships' do
      let!(:source_day) do
        create(:day,
               calendar: source_calendar,
               period_start_date: Date.parse('2023-09-11'),
               period_end_date: Date.parse('2023-09-17'))
      end

      let!(:match_in_source) do
        create(:match,
               championship: source_championship,
               day: source_day)
      end

      let!(:match_availability) do
        create(:match_availability, match: match_in_source)
      end

      it 'merges calendars successfully' do
        result = target_championship.merge_calendar_from(source_championship)

        expect(result[:success]).to be true
        expect(source_championship.reload.calendar).to eq(target_calendar)
      end

      it 'creates new day in target calendar with normalized periods' do
        expect do
          target_championship.merge_calendar_from(source_championship)
        end.to change { target_calendar.days.count }.by(1)

        new_day = target_calendar.days.last
        expect(new_day.period_start_date).to eq(Date.parse('2023-09-11').beginning_of_week)
        expect(new_day.period_end_date).to eq(Date.parse('2023-09-17').end_of_week)
      end

      it 'reassigns matches to new day' do
        target_championship.merge_calendar_from(source_championship)

        match_in_source.reload
        expect(match_in_source.day.calendar).to eq(target_calendar)
      end

      it 'preserves match availabilities' do
        target_championship.merge_calendar_from(source_championship)

        expect(match_in_source.reload.match_availabilities.count).to eq(1)
        expect(match_in_source.match_availabilities.first).to eq(match_availability)
      end

      it 'deletes source calendar when no other championships reference it' do
        source_calendar_id = source_calendar.id

        target_championship.merge_calendar_from(source_championship)

        expect(Calendar.exists?(source_calendar_id)).to be false
      end
    end

    context 'when days have matching periods' do
      let!(:target_day) do
        create(:day,
               calendar: target_calendar,
               period_start_date: Date.parse('2023-09-11').beginning_of_week,
               period_end_date: Date.parse('2023-09-17').end_of_week)
      end

      let!(:source_day) do
        create(:day,
               calendar: source_calendar,
               period_start_date: Date.parse('2023-09-11'),
               period_end_date: Date.parse('2023-09-17'))
      end

      let!(:match_in_source) { create(:match, championship: source_championship, day: source_day) }

      it 'does not create duplicate days' do
        expect do
          target_championship.merge_calendar_from(source_championship)
        end.not_to(change { target_calendar.days.count })
      end

      it 'merges matches into existing day' do
        target_championship.merge_calendar_from(source_championship)

        expect(match_in_source.reload.day).to eq(target_day)
      end
    end

    context 'when source calendar has multiple championships' do
      let!(:another_championship) { create(:championship, calendar: source_calendar, season:) }

      let!(:source_day) do # rubocop:disable RSpec/LetSetup
        create(:day,
               calendar: source_calendar,
               period_start_date: Date.parse('2023-09-11'),
               period_end_date: Date.parse('2023-09-17'))
      end

      it 'does not delete source calendar' do
        source_calendar_id = source_calendar.id

        target_championship.merge_calendar_from(source_championship)

        expect(Calendar.exists?(source_calendar_id)).to be true
        expect(another_championship.reload.calendar).to eq(source_calendar)
      end
    end

    context 'with validation errors' do
      it 'returns error when merging with itself' do
        result = target_championship.merge_calendar_from(target_championship)

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Cannot merge a championship with itself')
      end

      it 'returns error when calendars already the same' do
        source_championship.update!(calendar: target_calendar)

        result = target_championship.merge_calendar_from(source_championship)

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Championships already share the same calendar')
      end

      it 'returns error when seasons differ' do
        different_season = create(:season)
        source_championship.update!(season: different_season)

        result = target_championship.merge_calendar_from(source_championship)

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Cannot merge calendars from different seasons')
      end
    end
  end
end
