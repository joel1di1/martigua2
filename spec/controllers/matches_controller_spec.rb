# frozen_string_literal: true

require 'rails_helper'

describe MatchesController do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }
  let(:championship) { create(:championship) }

  before { sign_in user }

  describe 'GET new' do
    let(:do_request) { get :new, params: { section_id: section, championship_id: championship } }

    before { do_request }

    it { expect(response).to have_http_status(:success) }
    it { expect(assigns[:match]).not_to be_nil }
  end

  describe 'POST selection' do
    let(:local_team) { create(:team) }
    let(:visitor_team) { create(:team) }
    let(:match) { create(:match, visitor_team:, local_team:) }
    let(:params) { { section_id: section, id: match, user_id: user.id, team_id: local_team.id, format: } }

    let(:do_request) { post :selection, params: }

    describe 'response' do
      before { do_request }

      context 'with json' do
        let(:format) { :json }

        it { expect(response).to have_http_status(:created) }
      end
    end

    context 'with json' do
      let(:format) { :json }

      it { expect { do_request }.to change(Selection, :count).by(1) }
    end
  end
end
