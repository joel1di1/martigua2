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

    context 'with training' do
      let(:training) { create(:training, with_section: section, start_datetime: 2.days.from_now) }

      before { training }

      it 'displays training' do
        get "/sections/#{section.id}/events"

        expect(response.body).to include(I18n.l(training.start_datetime, format: '%a %d %b %R'))
      end
    end
  end
end
