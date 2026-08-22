# frozen_string_literal: true

require 'rails_helper'

describe 'ParticipationsRenewal' do
  let(:section) { create(:section) }
  let(:coach) { create(:user, with_section_as_coach: section) }

  before { sign_in coach, scope: :user }

  describe 'GET index' do
    let(:request_params) { { section_id: section.to_param } }
    let(:request) { get section_participations_renewal_index_path(section) }

    let(:player_from_previous_season) { create(:user) }
    let(:player_from_previous_season2) { create(:user) }
    let(:coach_from_previous_season) { create(:user) }
    let(:player_and_coach_from_previous_season) { create(:user) }
    let(:player_from_current_season) { create(:user) }
    let(:coach_from_current_season) { create(:user) }

    before do
      previous_season = Season.current.previous
      section.add_player!(player_from_previous_season, season: previous_season)
      section.add_player!(player_from_previous_season2, season: previous_season)
      section.add_coach!(coach_from_previous_season, season: previous_season)
      section.add_player!(player_and_coach_from_previous_season, season: previous_season)
      section.add_coach!(player_and_coach_from_previous_season, season: previous_season)
      section.add_player!(player_from_current_season)
      section.add_coach!(coach_from_current_season)

      request
    end

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template(:index) }
  end

  describe 'POST create' do
    let(:previous_season) { Season.current.previous }
    let(:player_from_previous_season) { create(:user) }

    before { section.add_player!(player_from_previous_season, season: previous_season) }

    it 'renews a player who was a member of the section in the previous season' do
      post section_participations_renewal_index_path(section), params: { players_ids: [player_from_previous_season.id] }
      expect(section.players.exists?(player_from_previous_season.id)).to be(true)
    end

    context 'when the user was never a member of the section' do
      let(:other_user) { create(:user) }

      it 'does not add the user to the section and redirects with an error' do
        post section_participations_renewal_index_path(section), params: { players_ids: [other_user.id] }
        expect(section.reload.players.exists?(other_user.id)).to be(false)
        expect(response).to redirect_to(section_participations_renewal_index_path(section))
      end
    end

    context 'when renewing several members and one of them was both a player and a coach' do
      let(:player_and_coach_from_previous_season) { create(:user) }
      let(:another_player_from_previous_season) { create(:user) }

      before do
        section.add_player!(player_and_coach_from_previous_season, season: previous_season)
        section.add_coach!(player_and_coach_from_previous_season, season: previous_season)
        section.add_player!(another_player_from_previous_season, season: previous_season)
      end

      it 'renews every selected player without raising RecordNotFound' do
        post section_participations_renewal_index_path(section),
             params: { players_ids: [player_and_coach_from_previous_season.id, another_player_from_previous_season.id] }

        expect(section.reload.players.exists?(player_and_coach_from_previous_season.id)).to be(true)
        expect(section.reload.players.exists?(another_player_from_previous_season.id)).to be(true)
        expect(response).to redirect_to(section_users_path(section))
      end
    end
  end
end
