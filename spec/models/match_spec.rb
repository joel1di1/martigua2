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
    subject { described_class.date_ordered }

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
             ffhb_key: '16-ans-masculins-2-eme-division-territoriale-23229 128335 1891863',
             start_datetime: nil,
             meeting_datetime: nil)
    end

    before do
      mock_ffhb
      match.ffhb_sync!
      match.reload
    end

    it { expect(match.start_datetime).to eq Time.zone.local(2023, 9, 16, 18, 30) }
    it { expect(match.meeting_datetime).to eq Time.zone.local(2023, 9, 16, 17, 30) }
    it { expect(match.local_score).to eq 25 }
    it { expect(match.visitor_score).to eq 30 }

    it {
      expect(match.location.address).to eq("gymnase abel-rospide (ex jean-mace)\nCHEMIN DES BOUTAREINES\n94350 VILLIERS SUR MARNE")
    }

    it { expect(match.location.name).to eq('gymnase abel-rospide (ex jean-mace)') }
    it { expect(match.location.ffhb_id).to eq '1395' }
  end
end
