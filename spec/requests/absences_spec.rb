# frozen_string_literal: true

require 'rails_helper'

describe 'Absences' do
  let(:section) { create(:section) }
  let(:coach) { create(:user, with_section_as_coach: section) }
  let(:player) { create(:user, with_section: section) }

  before { sign_in coach, scope: :user }

  describe 'GET new' do
    it 'succeeds for a user belonging to the current section' do
      get new_section_user_absence_path(section_id: section.to_param, user_id: player.to_param)
      expect(response).to have_http_status(:success)
    end

    it 'returns not_found for a user belonging to another section' do
      other_user = create(:user, with_section: create(:section))
      get new_section_user_absence_path(section_id: section.to_param, user_id: other_user.to_param)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST create' do
    let(:params) { { absence: { start_at: 1.day.ago, end_at: 1.week.from_now, name: 'Blessure' } } }

    it 'creates an absence for a user belonging to the current section' do
      expect do
        post section_user_absences_path(section_id: section.to_param, user_id: player.to_param), params: params
      end.to change(Absence, :count).by(1)
      expect(Absence.last.user).to eq(player)
    end

    it 'returns not_found for a user belonging to another section' do
      other_user = create(:user, with_section: create(:section))
      expect do
        post section_user_absences_path(section_id: section.to_param, user_id: other_user.to_param), params: params
      end.not_to change(Absence, :count)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE destroy' do
    let(:absence) { create(:absence, user: player) }

    it 'destroys an absence belonging to a user of the current section' do
      absence
      expect do
        delete section_user_absence_path(section_id: section.to_param, user_id: player.to_param, id: absence.id)
      end.to change(Absence, :count).by(-1)
    end

    context 'when the absence belongs to a user from another section' do
      let(:other_user) { create(:user, with_section: create(:section)) }
      let(:other_absence) { create(:absence, user: other_user) }

      it 'returns not_found and does not destroy the absence' do
        other_absence
        expect do
          delete section_user_absence_path(section_id: section.to_param, user_id: other_user.to_param,
                                           id: other_absence.id)
        end.not_to change(Absence, :count)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the absence belongs to another user of the current section' do
      let(:other_player) { create(:user, with_section: section) }
      let(:other_absence) { create(:absence, user: other_player) }

      it 'returns not_found and does not destroy the absence' do
        other_absence
        expect do
          delete section_user_absence_path(section_id: section.to_param, user_id: player.to_param, id: other_absence.id)
        end.not_to change(Absence, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
