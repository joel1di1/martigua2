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
    let!(:day) { create(:day, calendar:, name: 'J1 - 16 Sep - 17 Sep', period_start_date: Date.new(2017, 9, 16)) }

    before { get edit_section_calendar_path(section, calendar) }

    it { expect(response).to have_http_status(:success) }
    it { expect(response.body).to include(calendar.name) }
    it { expect(response.body).to include(day.name, I18n.l(day.period_start_date, locale: :fr)) }
  end

  describe 'GET /sections/:section_id/calendars/:id/edit without days' do
    let(:calendar) { create(:calendar) }

    before { get edit_section_calendar_path(section, calendar) }

    it { expect(response).to have_http_status(:success) }
    it { expect(response.body).to include('Aucune journée dans ce calendrier.') }
  end

  describe 'POST /sections/:section_id/calendars' do
    let(:season) { create(:season) }

    it 'creates the calendar and redirects to the calendar list' do
      expect do
        post section_calendars_path(section), params: { calendar: { name: 'Coupe', season_id: season.id } }
      end.to change(Calendar, :count).by(1)

      expect(response).to redirect_to(section_calendars_path(section))
    end
  end
end
