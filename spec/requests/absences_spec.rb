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

  describe 'permissions' do
    let(:params) { { absence: { start_at: Time.zone.today, end_at: 1.week.from_now.to_date, name: 'Blessure' } } }

    context 'when a plain member acts on a teammate through the section routes' do
      before { sign_in create(:user, with_section: section), scope: :user }

      it 'forbids new' do
        get new_section_user_absence_path(section, player)
        expect(response).to have_http_status(:forbidden)
      end

      it 'forbids create' do
        expect { post section_user_absences_path(section, player), params: }.not_to change(Absence, :count)
        expect(response).to have_http_status(:forbidden)
      end

      it 'forbids destroy' do
        absence = create(:absence, user: player)
        expect { delete section_user_absence_path(section, player, absence) }.not_to change(Absence, :count)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when a player manages own absences through the section routes' do
      before { sign_in player, scope: :user }

      it 'creates the absence' do
        expect { post section_user_absences_path(section, player), params: }.to change(Absence, :count).by(1)
        expect(response).to redirect_to(section_user_path(section, player))
      end
    end

    context 'when the owner uses the sectionless routes' do
      before { sign_in player, scope: :user }

      it 'renders new' do
        get new_user_absence_path(player)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(user_absences_path(player))
      end

      it 'creates the absence' do
        expect { post user_absences_path(player), params: }.to change(player.absences, :count).by(1)
        expect(response).to redirect_to(user_path(player))
      end

      it 'updates the absence' do
        absence = create(:absence, user: player, name: 'Maladie')
        patch user_absence_path(player, absence), params: params
        expect(absence.reload.name).to eq('Blessure')
        expect(response).to redirect_to(user_path(player))
      end

      it 'destroys the absence' do
        absence = create(:absence, user: player)
        expect { delete user_absence_path(player, absence) }.to change(Absence, :count).by(-1)
        expect(response).to redirect_to(user_path(player))
      end
    end

    context 'when another user uses the sectionless routes' do
      it 'forbids a coach of the owner section, since no section is given' do
        expect { post user_absences_path(player), params: }.not_to change(Absence, :count)
        expect(response).to have_http_status(:forbidden)
      end

      it 'forbids edit' do
        absence = create(:absence, user: player)
        get edit_user_absence_path(player, absence)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
