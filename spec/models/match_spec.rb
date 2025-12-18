# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Match do
  it { is_expected.to belong_to :local_team }
  it { is_expected.to belong_to :visitor_team }
  it { is_expected.to belong_to :day }

  it { is_expected.to have_many :selections }

  describe '#date' do
    let(:day) { create(:day) }
    let(:match) { create(:match, start_datetime:, day:) }

    context 'with specified start_datetime' do
      let(:start_datetime) { 1.week.from_now }

      it { expect(match.date).to eq start_datetime.to_fs(:short) }
    end

    context 'with no start_datetime specified' do
      let(:start_datetime) { nil }

      it { expect(match.date).to eq day.name }
    end
  end

  describe '#users' do
    subject { match.users }

    let(:previous_season) { create(:season, start_date: 2.years.ago) }
    let(:player) { create(:user) }
    let(:team) { create(:team) }
    let(:section) { create(:section, teams: [team]) }
    let(:match) { create(:match, local_team: team) }

    context 'with user participating in the current season' do
      before do
        section.add_player!(player)
      end

      it { is_expected.to include(player) }
    end

    context 'with user not participating in the current season but in the previous' do
      before do
        section.add_player!(player, season: previous_season)
      end

      it { is_expected.not_to include(player) }
    end

    context 'with user participating in the current season and the previous' do
      before do
        section.add_player!(player, season: previous_season)
        section.add_player!(player)
      end

      it { is_expected.to include(player) }
    end
  end

  describe '#date_ordered' do
    subject { Match.date_ordered }

    before do
      create(:match)
    end

    it { is_expected.not_to be_empty }
  end

  describe '#meeting_datetime' do
    subject(:datetime) { Match.new(meeting_datetime:, start_datetime:).meeting_datetime }

    context 'with meeting_datetime specified' do
      let(:meeting_datetime) { 1.day.from_now }
      let(:start_datetime) { 2.days.from_now }

      it { expect(datetime).to eq(meeting_datetime) }
    end

    context 'with meeting_datetime not specified and start_datetime specified' do
      let(:meeting_datetime) { nil }
      let(:start_datetime) { 2.days.from_now }

      it { expect(datetime).to eq(start_datetime - 1.hour) }
    end

    context 'with meeting_datetime not specified and start_datetime not specified' do
      let(:meeting_datetime) { nil }
      let(:start_datetime) { nil }

      it { expect(datetime).to be_nil }
    end
  end

  describe '.burned?' do
    let(:user) { create(:user) }
    let(:section) { create(:section) }
    let(:championship) { create(:championship, season: Season.current) }
    let(:match) { create(:match, championship:) }

    before { create(:team, with_section: section, enrolled_in: championship) }

    it 'returns boolean' do
      expect(match.reload).not_to be_burned(user)
      championship.burn!(user)
      expect(match.reload).to be_burned(user)
      championship.unburn!(user)
      expect(match.reload).not_to be_burned(user)
    end
  end

  describe '#ffhb_sync!' do
    let(:match) do
      create(:match,
             ffhb_key: '16-ans-m-2-eme-division-territoriale-94-75-23229 128335 1891863',
             start_datetime: nil,
             meeting_datetime: nil)
    end

    before do
      mock_ffhb
      match.ffhb_sync!
      match.reload
    end

    it { expect(match.start_datetime).to eq Time.zone.local(2023, 9, 16, 20, 30) }
    it { expect(match.meeting_datetime).to eq Time.zone.local(2023, 9, 16, 19, 30) }
    it { expect(match.local_score).to eq 25 }
    it { expect(match.visitor_score).to eq 30 }

    it {
      expect(match.location.address).to eq("gymnase abel-rospide (ex jean-mace)\nCHEMIN DES BOUTAREINES\n94350 VILLIERS SUR MARNE")
    }

    it { expect(match.location.name).to eq('gymnase abel-rospide (ex jean-mace)') }
    it { expect(match.location.ffhb_id).to eq '1395' }

    it { expect(match.day.name).to eq('Week 2023-09-11 2023-09-17') }
  end

  describe '#ffhb_sync! with several days on same period' do
    let(:day1) do
      create(:day, period_start_date: '2023-09-11', period_end_date: '2023-09-17',
                   calendar: match.championship.calendar)
    end
    let(:day2) do
      create(:day, period_start_date: '2023-09-11', period_end_date: '2023-09-17',
                   calendar: match.championship.calendar)
    end

    let(:match) do
      create(:match,
             ffhb_key: '16-ans-m-2-eme-division-territoriale-94-75-23229 128335 1891863',
             start_datetime: nil,
             meeting_datetime: nil)
    end

    before do
      mock_ffhb
      # initialize day1 before day2 and before the match, so day1 is the first day
      day1
      match.update!(day: day2)
    end

    it 'associate the match with the last day' do
      match.ffhb_sync!
      match.reload
      expect(match.day.id).to eq(day2.id)
    end
  end

  describe '#ffhb_sync! when match is deleted (team banished)' do
    let(:match) do
      create(:match,
             ffhb_key: '16-ans-m-2-eme-division-territoriale-94-75-23229 128335 1891863',
             start_datetime: nil)
    end

    before do
      allow(FfhbService.instance).to receive(:fetch_match_details)
        .and_raise(FfhbServiceError, "Smartfire component 'competitions---rematch' not found at URL: https://example.com")
    end

    it 'captures warning to Sentry with context' do
      expect(Sentry).to receive(:capture_message).with(
        'FFHB sync failed for match - possibly deleted match (team banished?)',
        hash_including(
          level: :warning,
          extra: hash_including(
            match_id: match.id,
            match_ffhb_key: match.ffhb_key,
            championship_id: match.championship_id
          )
        )
      )

      expect { match.ffhb_sync! }.not_to raise_error
    end

    it 'logs warning' do
      allow(Sentry).to receive(:capture_message)
      expect(Rails.logger).to receive(:warn).with(/FFHB sync failed for match/)

      match.ffhb_sync!
    end
  end

  describe '#aways' do
    context 'with a player sick' do
      let(:section) { create(:section) }
      let(:team) { create(:team, with_section: section) }
      let(:match) { create(:match, local_team: team) }
      let(:player) { create(:user, with_section: section) }
      let(:player_sick) { create(:user, with_section: section) }

      before do
        create(:match_availability, user: player, match:, available: true)
        create(:match_availability, user: player_sick, match:, available: true)
        create(:absence, user: player_sick, start_at: match.start_datetime - 1.day,
                         end_at: match.start_datetime + 2.days)
        [player, player_sick]
      end

      it { expect(match.aways).to contain_exactly(player_sick) }
      it { expect(match.availables).to contain_exactly(player) }
      it { expect(match.nb_availables).to eq 1 }
      it { expect(match.nb_not_availables).to eq 1 }
      it { expect(match.not_availables).to contain_exactly(player_sick) }
    end

    context 'with absence matching exact match boundaries using end_datetime' do
      let(:section) { create(:section) }
      let(:team) { create(:team, with_section: section) }
      let(:day) { create(:day, period_start_date: 1.week.from_now, period_end_date: 1.week.from_now + 2.hours) }
      let(:match) do
        create(:match, local_team: team, day:, start_datetime: 1.week.from_now,
                       end_datetime: 1.week.from_now + 2.hours)
      end
      let(:player) { create(:user, with_section: section) }
      let(:player_absent) { create(:user, with_section: section) }

      before do
        create(:match_availability, user: player, match:, available: true)
        create(:match_availability, user: player_absent, match:, available: true)
        # Absence that covers match period using end_datetime (not start_datetime)
        create(:absence, user: player_absent, start_at: match.start_datetime - 1.hour,
                         end_at: match.end_datetime + 1.hour)
        [player, player_absent]
      end

      it 'includes player with absence covering match period' do
        expect(match.aways).to contain_exactly(player_absent)
      end
    end

    context 'with match using day period when start_datetime is nil' do
      let(:section) { create(:section) }
      let(:team) { create(:team, with_section: section) }
      let(:day) { create(:day, period_start_date: 1.week.from_now, period_end_date: 1.week.from_now + 2.hours) }
      let(:match) { create(:match, local_team: team, day:, start_datetime: nil, end_datetime: nil) }
      let(:player) { create(:user, with_section: section) }
      let(:player_absent) { create(:user, with_section: section) }

      before do
        create(:match_availability, user: player, match:, available: true)
        create(:match_availability, user: player_absent, match:, available: true)
        # Absence covering the day period
        create(:absence, user: player_absent, start_at: day.period_start_date - 1.hour,
                         end_at: day.period_end_date + 1.hour)
        [player, player_absent]
      end

      it 'uses day period for absence checking' do
        expect(match.aways).to contain_exactly(player_absent)
      end
    end
  end

  describe '#calculated_start_datetime' do
    let(:day) { create(:day) }
    let(:match) { create(:match, start_datetime:, day:) }

    context 'with start_datetime specified' do
      let(:start_datetime) { 2.days.from_now }

      it { expect(match.calculated_start_datetime).to eq start_datetime }
    end

    context 'with start_datetime not specified' do
      let(:start_datetime) { nil }

      it { expect(match.calculated_start_datetime).to eq day.period_start_date }
    end
  end
end
