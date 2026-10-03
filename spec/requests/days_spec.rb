# frozen_string_literal: true

require 'rails_helper'

describe 'Days' do
  let(:section) { create(:section) }
  let(:coach) { create(:user, with_section_as_coach: section) }
  let(:championship) { create(:championship) }
  let(:day) { create(:day) }

  before do
    create(:team, with_section: section, enrolled_in: championship)
    sign_in coach, scope: :user
  end

  describe 'POST create from the calendar edit page' do
    let(:calendar) { create(:calendar) }
    let(:edit_calendar_path) { edit_section_calendar_path(section, calendar) }

    it 'creates the day and redirects back to the calendar' do
      expect do
        post section_days_path(section),
             params: { _redirect_url: edit_calendar_path,
                       day: { name: 'J1', period_start_date: '2026-09-12', calendar_id: calendar.id } }
      end.to change(calendar.days, :count).by(1)

      expect(response.location).to start_with("http://www.example.com#{edit_calendar_path}?")
    end
  end

  describe 'PATCH update' do
    subject(:do_update) do
      patch section_day_path(section_id: section.to_param, id: day.id), params: { selection_hidden: true }
    end

    context 'when the day has a match belonging to the current section' do
      before { create(:match, championship:, day:) }

      it 'updates the day' do
        do_update
        expect(day.reload.selection_hidden).to be(true)
      end
    end

    context 'when the day has no match belonging to the current section' do
      it 'returns not_found and does not update the day' do
        do_update
        expect(response).to have_http_status(:not_found)
        expect(day.reload.selection_hidden).to be(false)
      end
    end

    context 'when the day only has matches belonging to another section' do
      let(:other_championship) { create(:championship) }

      before { create(:match, championship: other_championship, day:) }

      it 'returns not_found and does not update the day' do
        do_update
        expect(response).to have_http_status(:not_found)
        expect(day.reload.selection_hidden).to be(false)
      end
    end
  end
end
