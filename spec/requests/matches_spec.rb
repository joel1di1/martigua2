# frozen_string_literal: true

require 'rails_helper'

describe 'Matches' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }
  let(:championship) { create(:championship) }

  before { sign_in user, scope: :user }

  describe 'GET new' do
    let(:do_request) { get new_section_championship_match_path(section, championship) }

    before { do_request }

    it { expect(response).to have_http_status(:success) }
  end

  describe 'POST selection' do
    let(:local_team) { create(:team) }
    let(:visitor_team) { create(:team) }
    let(:match) { create(:match, visitor_team:, local_team:) }
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

      it { expect { do_request }.to change(Selection, :count).by(1) }
    end
  end
end