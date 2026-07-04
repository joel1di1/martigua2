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
