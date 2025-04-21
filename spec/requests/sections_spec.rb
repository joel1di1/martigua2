# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sections', type: :request do
  let(:club) { create(:club) }
  let(:user) { create(:user) }
  let(:section) { create(:section, club:) }

  describe 'GET /clubs/:club_id/sections/new' do
    context 'when user is authenticated' do
      before do
        club.add_admin!(user)
        get new_club_section_path(club), params: { user_email: user.email, user_token: user.authentication_token }
      end

      it { expect(response).to have_http_status(:success) }

      it 'renders the new template' do
        expect(response).to render_template(:new)
      end

      it 'includes section form in the response' do
        expect(response.body).to include('form')
        expect(response.body).to include('section[name]')
      end
    end

    context 'when user is not authenticated' do
      before do
        get new_club_section_path(club)
      end

      it { expect(response).to have_http_status(:found) }
    end

    context 'when user is authenticated but not authorized for this club' do
      let(:another_user) { create(:user) }

      before do
        get new_club_section_path(club), params: { user_email: another_user.email, user_token: another_user.authentication_token }
      end

      it { expect(response).to have_http_status(:redirect) }
    end
  end

  describe 'POST /clubs/:club_id/sections' do
    let(:section_attributes) { attributes_for(:section, club: nil) }
    let(:auth_params) do
      { user_email: user.email, user_token: user.authentication_token }
    end

    before do
      post club_sections_path(club), params: auth_params.merge(section: section_attributes), as: :json
    end

    it { expect(response).to have_http_status(:created) }

    it 'makes the user a coach of the section' do
      expect(user).to be_coach_of(Section.where(club:, name: section_attributes[:name]))
    end
  end

  describe 'GET /sections/:id' do
    before do
      sign_in user, scope: :user
      get section_path(section)
    end

    it { expect(response).to have_http_status(:success) }
    # Can't test assigns in request specs, but we can verify the response contains expected data
    # We could test specific content if needed
  end

  # NOTE: The #suggested_user_stat method test is a private method test that doesn't translate directly
  # to a request spec. These types of tests are typically handled differently:
  # 1. Test the observable behaviors through public endpoints
  # 2. Extract the method to a service object that can be tested directly
  # 3. Move the method to a model or concern where it makes more sense
end
