# frozen_string_literal: true

require 'rails_helper'

describe 'Championships' do
  let(:championships) { create(:championships) }
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section_as_coach: section) }
  let(:calendar) { create(:calendar) }

  describe 'GET new' do
    let(:do_request) { get new_section_championship_path(section) }

    before { sign_in user, scope: :user }

    it_behaves_like 'an endpoint denied to non-members of the section'

    describe 'response' do
      before { do_request }

      it { expect(response).to have_http_status(:success) }
    end
  end

  describe 'POST create' do
    let(:championship_params) { { name: Faker::Company.name, calendar_id: calendar.id } }
    let(:params) { { championship: championship_params } }
    let(:do_request) { post section_championships_path(section), params: params }

    before { sign_in user, scope: :user }

    it_behaves_like 'an endpoint denied to non-members of the section'

    it { expect { do_request }.to(change(Championship, :count)) }

    describe 'response' do
      before { do_request }

      it { expect(response).to redirect_to(section_championship_path(section, Championship.last)) }
    end
  end

  describe 'POST create from FFHB' do
    let(:my_team) { create(:team, with_section: section) }
    let(:other_team) { create(:team) }
    let(:ffhb_params) do
      { ffhb: '1',
        type_competition: 'D',
        code_comite: '94',
        code_competition: '16-ans-m-2-eme-division-territoriale-94-75-23229',
        phase_id: '41894',
        code_pool: '128335' }
    end
    let(:do_request) { post section_championships_path(section), params: ffhb_params.merge(team_links:) }

    before do
      mock_ffhb
      sign_in user, scope: :user
    end

    context 'when team_links reference a team of the section' do
      let(:team_links) { { '1589702' => my_team.id.to_s } }

      it 'links the team' do
        do_request
        expect(Championship.last.teams).to include(my_team)
      end
    end

    context "when team_links reference another club's team" do
      let(:team_links) { { '1589702' => other_team.id.to_s } }

      it 'ignores the foreign team and creates a placeholder instead' do
        do_request
        expect(Championship.last.teams).not_to include(other_team)
      end
    end
  end

  describe 'GET edit' do
    let(:championship) { create(:championship) }
    let(:championship_in_section) { true }
    let(:do_request) { get edit_section_championship_path(section, championship) }

    before do
      create(:team, with_section: section, enrolled_in: championship) if championship_in_section
      sign_in user, scope: :user
    end

    it_behaves_like 'an endpoint denied to non-members of the section'

    describe 'response' do
      before { do_request }

      it { expect(response).to have_http_status(:success) }
    end

    context 'when the championship does not belong to the section' do
      let(:championship_in_section) { false }

      before { do_request }

      it { expect(response).to have_http_status(:not_found) }
    end
  end

  describe 'POST update' do
    let(:championship) { create(:championship) }
    let(:championship_in_section) { true }
    let(:new_championship_params) { { name: Faker::Company.name } }
    let(:params) { { championship: new_championship_params } }

    before do
      create(:team, with_section: section, enrolled_in: championship) if championship_in_section
    end

    describe 'response' do
      before do
        sign_in user, scope: :user
        patch section_championship_path(section, championship), params: params
      end

      it { expect(response).to redirect_to(section_championship_path(section, championship)) }
      it { expect(championship.reload.name).to eq(new_championship_params[:name]) }
    end

    context 'when the championship belongs to another section' do
      let(:championship_in_section) { false }

      before do
        sign_in user, scope: :user
        patch section_championship_path(section, championship), params: params
      end

      it { expect(response).to have_http_status(:not_found) }
      it { expect(championship.reload.name).not_to eq(new_championship_params[:name]) }
    end
  end
end
