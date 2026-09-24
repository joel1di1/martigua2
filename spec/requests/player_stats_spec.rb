# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PlayerStats' do
  let(:club) { create(:club) }
  let(:section) { create(:section, club:) }
  let(:championship) { create(:championship, season: Season.current) }
  let(:our_team) { create(:team, club:, with_section: section, enrolled_in: championship) }
  let(:opponent_team) { create(:team, enrolled_in: championship) }
  let(:match) do
    create(:match, championship:, local_team: our_team, visitor_team: opponent_team,
                   day: create(:day, calendar: championship.calendar))
  end
  let(:user) { create(:user, with_section: section) }

  before { sign_in user, scope: :user }

  describe 'GET /index' do
    it 'returns http success' do
      get "/sections/#{section.id}/player_stats"

      expect(response).to have_http_status(:success)
    end

    it 'only displays players belonging to the section teams, not opponents' do
      our_stat = create(:player_match_stat, match:, team: our_team, last_name: 'OURPLAYER')
      create(:player_match_stat, match:, team: opponent_team, last_name: 'OPPONENTPLAYER')

      get "/sections/#{section.id}/player_stats"

      expect(response.body).to include(our_stat.last_name)
      expect(response.body).not_to include('OPPONENTPLAYER')
    end
  end
end
