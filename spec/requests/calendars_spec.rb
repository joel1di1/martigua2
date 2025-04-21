# frozen_string_literal: true

require 'rails_helper'

describe 'Calendars' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section_as_coach: section) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET /sections/:section_id/calendars' do
    let!(:calendar1) { create(:calendar) }
    let!(:calendar2) { create(:calendar) }

    before { get section_calendars_path(section) }

    it { expect(response).to have_http_status(:success) }
    it { expect(response.body).to include(calendar1.name, calendar2.name) }
  end

  describe 'GET /sections/:section_id/calendars/:id/edit' do
    let(:calendar) { create(:calendar) }

    before { get edit_section_calendar_path(section, calendar) }

    it { expect(response).to have_http_status(:success) }
    it { expect(response.body).to include(calendar.name) }
  end
end
