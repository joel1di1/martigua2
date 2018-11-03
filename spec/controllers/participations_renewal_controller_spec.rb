require "rails_helper"

describe ParticipationsRenewalController, :type => :controller do
  let(:section) { create :section }
  let(:coach) { create :user, with_section_as_coach: section }

  before { sign_in coach }

  describe 'GET index' do
    let(:request_params) { { section_id: section.to_param } }
    let(:request) { get :index, params: request_params }

    let(:player_from_previous_season) { create :user }
    let(:player_from_previous_season_2) { create :user }
    let(:coach_from_previous_season) { create :user }
    let(:player_and_coach_from_previous_season) { create :user }
    let(:player_from_current_season) { create :user }
    let(:coach_from_current_season) { create :user }

    let(:expected_members) do
      [
        player_from_previous_season,
        player_from_previous_season_2,
        coach_from_previous_season,
        player_and_coach_from_previous_season,
      ]
    end

    before do
      previous_season = Season.current.previous
      section.add_player!(player_from_previous_season, season: previous_season)
      section.add_player!(player_from_previous_season_2, season: previous_season)
      section.add_coach!(coach_from_previous_season, season: previous_season)
      section.add_player!(player_and_coach_from_previous_season, season: previous_season)
      section.add_coach!(player_and_coach_from_previous_season, season: previous_season)
      section.add_player!(player_from_current_season)
      section.add_coach!(coach_from_current_season)
    end

    before { request }

    it { expect(assigns[:previous_season_members]).to match_array(expected_members) }
    it { expect(assigns[:previous_season]).to eq Season.current.previous }
  end

  describe 'POST create' do
  end
end
