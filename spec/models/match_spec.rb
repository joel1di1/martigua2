# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Match, :type => :model do
  it { should belong_to :local_team }
  it { should belong_to :visitor_team }
  it { should belong_to :day }

  it { should have_many :selections }

  it { should validate_presence_of :day }

  describe "#date" do
    let(:day) { create :day }
    let(:match) { create :match, start_datetime: start_datetime, day: day }

    context "with specified start_datetime" do
      let(:start_datetime) { 1.week.from_now }

      it { expect(match.date).to eq start_datetime.to_s(:short) }
    end

    context "with no start_datetime specified" do
      let(:start_datetime) { nil }

      it { expect(match.date).to eq day.name }
    end
  end

  describe '#users' do
    subject { match.users }

    let(:previous_season) { create :season, start_date: 2.years.ago }
    let(:player) { create :user }
    let(:team) { create :team }
    let(:section) { create :section, teams: [team] }
    let(:match) { create :match, local_team: team }

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
end
