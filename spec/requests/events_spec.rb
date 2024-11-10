# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Events' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }

  before { sign_in user }

  describe 'GET /index' do
    it 'returns http success' do
      get "/sections/#{section.id}/events"

      expect(response).to have_http_status(:success)
    end
  end
end
