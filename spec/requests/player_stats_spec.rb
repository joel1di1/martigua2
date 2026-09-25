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

    it "links the player's name to their profile when linked to a user" do
      linked_user = create(:user, with_section: section)
      create(:player_match_stat, match:, team: our_team, user: linked_user, last_name: 'LINKEDPLAYER')

      get "/sections/#{section.id}/player_stats"

      expect(response.body).to include(section_user_path(section, linked_user))
    end

    it "does not link the player's name when not linked to a user" do
      create(:player_match_stat, match:, team: our_team, user: nil, last_name: 'UNLINKEDPLAYER')

      get "/sections/#{section.id}/player_stats"

      name_cell = response.parsed_body.css('td').find { |td| td.text.include?('UNLINKEDPLAYER') }
      expect(name_cell.at_css('a')).to be_nil
    end

    it 'shows an association dropdown for unlinked players when the current user is a coach' do
      sign_in create(:user, with_section_as_coach: section), scope: :user
      create(:player_match_stat, match:, team: our_team, user: nil, last_name: 'UNLINKEDPLAYER')

      get "/sections/#{section.id}/player_stats"

      expect(response.body).to include(associate_player_section_player_stats_path(section))
    end

    it 'does not show an association dropdown for unlinked players to a non-coach' do
      create(:player_match_stat, match:, team: our_team, user: nil, last_name: 'UNLINKEDPLAYER')

      get "/sections/#{section.id}/player_stats"

      expect(response.body).not_to include(associate_player_section_player_stats_path(section))
    end
  end

  describe 'PATCH /associate_player' do
    let(:coach) { create(:user, with_section_as_coach: section) }
    let(:player_to_link) { create(:user, with_section: section) }
    let!(:stat) { create(:player_match_stat, match:, team: our_team, user: nil, first_name: 'jean', last_name: 'DUPONT') }

    it 'associates the FFHB player with the chosen section player' do
      sign_in coach, scope: :user

      patch "/sections/#{section.id}/player_stats/associate_player",
            params: { player_id: stat.player_id, first_name: stat.first_name, last_name: stat.last_name, user_id: player_to_link.id }

      expect(stat.reload.user_id).to eq(player_to_link.id)
      expect(response).to redirect_to(section_player_stats_path(section))
    end

    it 'links every stat row sharing the same player_id, across matches' do
      sign_in coach, scope: :user
      other_match = create(:match, championship:, local_team: our_team, visitor_team: opponent_team,
                                   day: create(:day, calendar: championship.calendar))
      other_stat = create(:player_match_stat, match: other_match, team: our_team, user: nil,
                                              player_id: stat.player_id, first_name: 'jean', last_name: 'DUPONT')

      patch "/sections/#{section.id}/player_stats/associate_player",
            params: { player_id: stat.player_id, first_name: stat.first_name, last_name: stat.last_name, user_id: player_to_link.id }

      expect(other_stat.reload.user_id).to eq(player_to_link.id)
    end

    it 'is forbidden for a non-coach' do
      patch "/sections/#{section.id}/player_stats/associate_player",
            params: { player_id: stat.player_id, first_name: stat.first_name, last_name: stat.last_name, user_id: player_to_link.id }

      expect(response).to have_http_status(:forbidden)
      expect(stat.reload.user_id).to be_nil
    end

    it 'only allows associating with a player from the section' do
      sign_in coach, scope: :user
      outsider = create(:user)

      patch "/sections/#{section.id}/player_stats/associate_player",
            params: { player_id: stat.player_id, first_name: stat.first_name, last_name: stat.last_name, user_id: outsider.id }

      expect(response).to have_http_status(:not_found)
      expect(stat.reload.user_id).to be_nil
    end
  end
end
