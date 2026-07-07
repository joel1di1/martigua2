# frozen_string_literal: true

require 'rails_helper'

describe 'ChampionshipFfhbImports' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section_as_coach: section) }

  before { mock_ffhb }

  describe 'GET new' do
    let(:do_request) { get new_section_championship_ffhb_import_path(section) }

    before { sign_in user, scope: :user }

    it_behaves_like 'an endpoint denied to non-members of the section'

    it 'renders the first step' do
      do_request
      expect(response).to have_http_status(:success)
    end

    it 'renders the team-linking step once all steps are selected' do
      get new_section_championship_ffhb_import_path(
        section,
        type_competition: 'D', code_comite: '94',
        code_competition: '16-ans-m-2-eme-division-territoriale-94-75-23229',
        phase_id: '41894', code_pool: '128335'
      )
      expect(response.body).to include('team_links')
    end
  end

  describe 'POST create' do
    let(:my_team) { create(:team, with_section: section) }
    let(:other_team) { create(:team) }
    let(:team_links) { { '1589702' => my_team.id.to_s } }
    let(:import_params) do
      { type_competition: 'D',
        code_comite: '94',
        code_competition: '16-ans-m-2-eme-division-territoriale-94-75-23229',
        phase_id: '41894',
        code_pool: '128335',
        team_links: }
    end
    let(:do_request) { post section_championship_ffhb_import_path(section), params: import_params }

    before { sign_in user, scope: :user }

    it_behaves_like 'an endpoint denied to non-members of the section'

    it { expect { do_request }.to change(Championship, :count).by(1) }

    it 'links the section team' do
      do_request
      expect(Championship.last.teams).to include(my_team)
    end

    context "when team_links reference another club's team" do
      let(:team_links) { { '1589702' => other_team.id.to_s } }

      it 'ignores the foreign team and creates a placeholder instead' do
        do_request
        expect(Championship.last.teams).not_to include(other_team)
      end
    end

    context 'when steps are incomplete' do
      let(:import_params) { { type_competition: 'D', code_comite: '94' } }

      it 'redirects back to the form with the selected steps' do
        do_request
        expect(response).to redirect_to(
          new_section_championship_ffhb_import_path(section, params: { type_competition: 'D', code_comite: '94' })
        )
      end

      it { expect { do_request }.not_to change(Championship, :count) }
    end
  end
end
