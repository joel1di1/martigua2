# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlayerMatchStat do
  describe 'associations' do
    it { is_expected.to belong_to(:match) }
    it { is_expected.to belong_to(:user).optional }
  end

  describe 'scopes' do
    let(:season) { create(:season) }
    let(:other_season) { create(:season, start_date: 2.years.ago) }
    let(:calendar) { create(:calendar, season: season) }
    let(:other_calendar) { create(:calendar, season: other_season) }
    let(:championship) { create(:championship, season: season, calendar: calendar) }
    let(:other_championship) { create(:championship, season: other_season, calendar: other_calendar) }
    let(:club) { create(:club) }
    let(:team1) { create(:team, club: club) }
    let(:team2) { create(:team, club: club) }
    let(:day) { create(:day, calendar: calendar) }
    let(:other_day) { create(:day, calendar: other_calendar) }
    let(:match) { create(:match, championship: championship, local_team: team1, visitor_team: team2, day: day, start_datetime: 1.week.ago) }
    let(:other_match) { create(:match, championship: other_championship, local_team: team1, visitor_team: team2, day: other_day, start_datetime: 1.year.ago) }
    let!(:stat) { create(:player_match_stat, match: match) }
    let!(:other_stat) { create(:player_match_stat, match: other_match) }

    describe '.for_season' do
      it 'returns stats for the given season' do
        expect(PlayerMatchStat.for_season(season)).to include(stat)
        expect(PlayerMatchStat.for_season(season)).not_to include(other_stat)
      end
    end

    describe '.for_championship' do
      it 'returns stats for the given championship' do
        expect(PlayerMatchStat.for_championship(championship)).to include(stat)
        expect(PlayerMatchStat.for_championship(championship)).not_to include(other_stat)
      end
    end

    describe '.in_date_range' do
      it 'returns stats for matches within the date range' do
        expect(PlayerMatchStat.in_date_range(2.weeks.ago, Time.zone.now)).to include(stat)
        expect(PlayerMatchStat.in_date_range(2.weeks.ago, Time.zone.now)).not_to include(other_stat)
      end
    end
  end
end
