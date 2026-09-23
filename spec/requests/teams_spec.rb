# frozen_string_literal: true

require 'rails_helper'

describe 'Teams' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }
  let(:coach) { create(:user, with_section_as_coach: section) }
  let(:team) { create(:team, with_section: section) }

  let(:section_path_param) { { section_id: section.to_param } }
  let(:team_path_param) { { id: team.to_param } }

  describe 'navigation link' do
    subject(:request) { get section_users_path(section_path_param) }

    context 'when signed in as coach' do
      before { sign_in coach, scope: :user }

      it 'shows the Équipes nav link' do
        request
        expect(response.body).to include('>Équipes<')
      end
    end

    context 'when signed in as a regular member' do
      before { sign_in user, scope: :user }

      it 'does not show the Équipes nav link' do
        request
        expect(response.body).not_to include('>Équipes<')
      end

      it 'can still access the teams index directly' do
        get section_teams_path(section_path_param)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET index' do
    subject(:request) { get section_teams_path(section_path_param) }

    before do
      sign_in user, scope: :user
      request
    end

    it { expect(response).to have_http_status(:success) }
  end

  describe 'GET new' do
    subject(:request) { get new_section_team_path(section_path_param) }

    context 'when signed in as coach' do
      before do
        sign_in coach, scope: :user
        request
      end

      it { expect(response).to have_http_status(:success) }
    end

    context 'when signed in as a regular member' do
      before do
        sign_in user, scope: :user
        request
      end

      it { expect(response).to have_http_status(:forbidden) }
    end
  end

  describe 'GET edit' do
    subject(:request) { get edit_section_team_path(section_path_param.merge(team_path_param)) }

    context 'when signed in as coach' do
      before do
        sign_in coach, scope: :user
        request
      end

      it { expect(response).to have_http_status(:success) }
    end

    context 'when signed in as a regular member' do
      before do
        sign_in user, scope: :user
        request
      end

      it { expect(response).to have_http_status(:forbidden) }
    end
  end

  describe 'POST create' do
    let(:create_request) do
      post section_teams_path(section_path_param), params: { team: { name: 'Les -18 masculins' } }
    end

    context 'when signed in as coach' do
      before { sign_in coach, scope: :user }

      it 'creates a new team attached to the section' do
        expect { create_request }.to change { section.teams.count }.by(1)
      end

      it 'redirects to the teams index' do
        create_request
        expect(response).to redirect_to(section_teams_path(section_path_param))
      end
    end

    context 'when signed in as a regular member' do
      before { sign_in user, scope: :user }

      it 'does not create a team' do
        expect { create_request }.not_to change(Team, :count)
      end

      it 'is forbidden' do
        create_request
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH update' do
    subject(:request) do
      patch section_team_path(section_path_param.merge(team_path_param)), params: { team: { name: 'Nouveau nom' } }
    end

    context 'when signed in as coach' do
      before { sign_in coach, scope: :user }

      it 'updates the team name' do
        request
        expect(team.reload.name).to eq('Nouveau nom')
      end

      it { is_expected.to redirect_to(section_teams_path(section_path_param)) }
    end

    context 'when signed in as a regular member' do
      before { sign_in user, scope: :user }

      it 'does not update the team name' do
        request
        expect(team.reload.name).not_to eq('Nouveau nom')
      end

      it 'is forbidden' do
        request
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE destroy' do
    subject(:request) { delete section_team_path(section_path_param.merge(team_path_param)) }

    context 'when signed in as coach' do
      before { sign_in coach, scope: :user }

      it 'destroys the team' do
        team
        expect { request }.to change(Team, :count).by(-1)
      end

      it { is_expected.to redirect_to(section_teams_path(section_path_param)) }

      context 'when the team already has matches' do
        before { create(:match, local_team: team) }

        it 'does not destroy the team' do
          expect { request }.not_to change(Team, :count)
        end
      end
    end

    context 'when signed in as a regular member' do
      before { sign_in user, scope: :user }

      it 'does not destroy the team' do
        team
        expect { request }.not_to change(Team, :count)
      end

      it 'is forbidden' do
        request
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
