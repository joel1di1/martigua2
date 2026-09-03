# frozen_string_literal: true

require 'rails_helper'

describe 'Matches' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }
  let(:championship) { create(:championship) }

  before { sign_in user, scope: :user }

  describe 'ownership scoping' do
    before { create(:team, with_section: section, enrolled_in: championship) }

    let(:match) { create(:match, championship:) }
    let(:other_championship) { create(:championship) }
    let(:other_match) { create(:match, championship: other_championship) }

    describe 'GET show' do
      it 'succeeds for a match belonging to the current section' do
        get section_match_path(section, match)
        expect(response).to have_http_status(:success)
      end

      it 'returns not_found for a match belonging to another section' do
        get section_match_path(section, other_match)
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'GET edit' do
      it 'succeeds for a match belonging to the current section' do
        get edit_section_championship_match_path(section, championship, match)
        expect(response).to have_http_status(:success)
      end

      it 'returns not_found for a match whose championship belongs to another section' do
        get edit_section_championship_match_path(section, other_championship, other_match)
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'PATCH update' do
      let(:params) { { match: { meeting_location: 'New location' } } }

      it 'updates a match belonging to the current section' do
        patch section_championship_match_path(section, championship, match), params: params
        expect(match.reload.meeting_location).to eq('New location')
      end

      it 'returns not_found for a match whose championship belongs to another section' do
        patch section_championship_match_path(section, other_championship, other_match), params: params
        expect(response).to have_http_status(:not_found)
        expect(other_match.reload.meeting_location).not_to eq('New location')
      end
    end

    # Regression net for ActionController::ParamsWrapper (see
    # spec/requests/webpush_subscriptions_spec.rb): a JSON request body must still
    # reach match_params. The controller has no `format.json`, so the request sends
    # a JSON body with the default Accept header, like a browser fetch would.
    describe 'PATCH update with a JSON request body' do
      let(:json_headers) { { 'CONTENT_TYPE' => 'application/json' } }

      it 'updates the match from a nested JSON body' do
        patch section_championship_match_path(section, championship, match),
              params: { match: { meeting_location: 'JSON location' } }.to_json, headers: json_headers

        expect(match.reload.meeting_location).to eq('JSON location')
      end

      it 'updates the match from a flat JSON body, thanks to parameter wrapping' do
        patch section_championship_match_path(section, championship, match),
              params: { meeting_location: 'Flat JSON location' }.to_json, headers: json_headers

        expect(match.reload.meeting_location).to eq('Flat JSON location')
      end
    end

    describe 'DELETE destroy' do
      it 'returns not_found for a match belonging to another section' do
        other_match
        expect do
          delete section_match_path(section, other_match)
        end.not_to change(Match, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET new' do
    let(:do_request) { get new_section_championship_match_path(section, championship) }

    it_behaves_like 'an endpoint denied to non-members of the section'

    describe 'response' do
      before { do_request }

      it { expect(response).to have_http_status(:success) }
    end
  end

  describe 'POST selection' do
    before { create(:team, with_section: section, enrolled_in: championship) }

    let(:local_team) { create(:team) }
    let(:visitor_team) { create(:team) }
    let(:match) { create(:match, championship:, visitor_team:, local_team:) }
    let(:params) { { user_id: user.id, team_id: local_team.id } }

    let(:do_request) { post selection_section_match_path(section, match, format: format), params: params }

    describe 'response' do
      before { do_request }

      context 'with json' do
        let(:format) { :json }

        it { expect(response).to have_http_status(:created) }
      end
    end

    context 'with json' do
      let(:format) { :json }

      it_behaves_like 'an endpoint denied to non-members of the section'

      it { expect { do_request }.to change(Selection, :count).by(1) }
    end

    context 'when user_id belongs to a user from another section' do
      let(:format) { :json }
      let(:other_user) { create(:user, with_section: create(:section)) }
      let(:params) { { user_id: other_user.id, team_id: local_team.id } }

      it 'returns not_found and does not create a selection' do
        expect { do_request }.not_to change(Selection, :count)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when team_id does not belong to the match' do
      let(:format) { :json }
      let(:other_team) { create(:team) }
      let(:params) { { user_id: user.id, team_id: other_team.id } }

      it 'returns not_found and does not create a selection' do
        expect { do_request }.not_to change(Selection, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
