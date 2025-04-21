# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Clubs' do
  let(:club) { create(:club) }
  let(:user) { create(:user) }

  describe 'GET /clubs/:id' do
    before do
      get club_path(club), params: { user_email: user.email, user_token: user.authentication_token }
    end

    it { expect(response).to have_http_status(:success) }
    # NOTE: We can't test assigns in request specs, but we can test that the response contains expected content
    # if needed for more thorough testing
  end
end
