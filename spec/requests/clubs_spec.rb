# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Clubs' do
  let(:club) { create(:club) }
  let(:user) { create(:user) }

  describe 'GET /clubs/:id' do
    before do
      get club_path(club), params: { user_token: user.generate_token_for(:email_authentication) }
    end

    it { expect(response).to have_http_status(:success) }
    # NOTE: We can't test assigns in request specs, but we can test that the response contains expected content
    # if needed for more thorough testing
  end

  describe 'GET /clubs/:id with an invalid or expired token' do
    it 'does not sign in with a garbage token' do
      get club_path(club), params: { user_token: 'not-a-real-token' }

      expect(response).to redirect_to(new_user_session_path)
    end

    it 'does not sign in with an expired token' do
      token = user.generate_token_for(:email_authentication)
      Timecop.travel 31.days.from_now
      get club_path(club), params: { user_token: token }
      Timecop.return

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
