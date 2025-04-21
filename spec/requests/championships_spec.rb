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

    it { expect { do_request }.to(change(Championship, :count)) }

    describe 'response' do
      before { do_request }

      it { expect(response).to redirect_to(section_championship_path(section, Championship.last)) }
    end
  end

  describe 'GET edit' do
    let(:championship) { create(:championship) }
    let(:do_request) { get edit_section_championship_path(section, championship) }

    before { sign_in user, scope: :user }

    describe 'response' do
      before { do_request }

      it { expect(response).to have_http_status(:success) }
    end
  end

  describe 'POST update' do
    let!(:championship) { create(:championship) }
    let(:new_championship_params) { { name: Faker::Company.name } }
    let(:params) { { championship: new_championship_params } }
    let(:do_request) { post section_championship_path(section, championship), params: params }

    before { sign_in user, scope: :user }

    describe 'response' do
      before { do_request }

      it { expect(response).to redirect_to(section_championship_path(section, championship)) }
    end
  end
end