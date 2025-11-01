# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team do
  it { is_expected.to belong_to :club }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to have_many :enrolled_team_championships }
  it { is_expected.to have_many :championships }

  describe '.team_with_match_on' do
    subject { Team.team_with_match_on(day, section) }

    let(:section) { create(:section) }
    let(:home_team1) { create(:team, sections: [section]) }
    let(:home_team2) { create(:team, sections: [section]) }

    let(:day) { create(:day) }

    context 'with no match' do
      it { is_expected.to match_array [] }
    end

    context 'with one team in one match' do
      let!(:match1) { create(:match, day:, local_team: home_team1) }

      it { is_expected.to contain_exactly([home_team1, match1]) }
    end

    context 'with two team in two different matches' do
      let!(:match1) { create(:match, day:, local_team: home_team1) }
      let!(:match2) { create(:match, day:, visitor_team: home_team2) }

      it { is_expected.to contain_exactly([home_team1, match1], [home_team2, match2]) }
    end

    context 'with two team in one match' do
      let!(:match1) { create(:match, day:, local_team: home_team1, visitor_team: home_team2) }

      it { is_expected.to contain_exactly([home_team1, match1], [home_team2, match1]) }
    end
  end
end
