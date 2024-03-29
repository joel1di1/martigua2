# frozen_string_literal: true

require 'rails_helper'

describe ClubsController do
  let(:club) { create(:club) }
  let(:user) { create(:user) }

  describe 'GET show' do
    let(:do_request) do
      get :show, params: { id: club.to_param, user_email: user.email, user_token: user.authentication_token }
    end

    before { do_request }

    it { expect(response).to have_http_status(:success) }
    it { expect(assigns(:club)).to eq(club) }
  end
end
