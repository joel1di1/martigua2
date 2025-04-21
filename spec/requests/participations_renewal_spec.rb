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
end