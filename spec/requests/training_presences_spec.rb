# frozen_string_literal: true

require 'rails_helper'

describe 'TrainingPresences' do
  let(:section) { create(:section) }
  let(:coach) { create(:user, with_section_as_coach: section) }
  let(:player) { create(:user, with_section: section) }
  let(:training) { create(:training, sections: [section]) }

  before { sign_in coach, scope: :user }

  describe 'GET show' do
    subject(:do_request) do
      get section_training_user_training_presence_path(section_id: section.to_param, training_id: training.id, user_id: player.id)
    end

    context 'when the training belongs to the current section' do
      before { create(:training_presence, user: player, training:, is_present: true) }

      it 'succeeds' do
        do_request
        expect(response).to have_http_status(:success)
      end
    end

    context 'when the training belongs to another section' do
      let(:other_training) { create(:training, sections: [create(:section)]) }

      it 'returns not_found' do
        get section_training_user_training_presence_path(section_id: section.to_param, training_id: other_training.id, user_id: player.id)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the user does not belong to the current section' do
      let(:other_player) { create(:user, with_section: create(:section)) }

      it 'returns not_found' do
        get section_training_user_training_presence_path(section_id: section.to_param, training_id: training.id, user_id: other_player.id)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST confirm_presence' do
    subject(:do_request) do
      post section_user_training_confirm_presence_path(section_id: section.to_param, user_id: player.id, training_id: training.id),
           params: { present: 'true' }
    end

    context 'when the training and user belong to the current section' do
      it 'confirms the presence' do
        do_request
        expect(player.training_presences.find_by(training:).presence_validated).to be(true)
      end
    end

    context 'when the training belongs to another section' do
      let(:other_training) { create(:training, sections: [create(:section)]) }

      it 'returns not_found and does not confirm any presence' do
        post section_user_training_confirm_presence_path(section_id: section.to_param, user_id: player.id, training_id: other_training.id),
             params: { present: 'true' }
        expect(response).to have_http_status(:not_found)
        expect(player.training_presences.find_by(training: other_training)).to be_nil
      end
    end

    context 'when the user does not belong to the current section' do
      let(:other_player) { create(:user, with_section: create(:section)) }

      it 'returns not_found and does not confirm any presence' do
        post section_user_training_confirm_presence_path(section_id: section.to_param, user_id: other_player.id, training_id: training.id),
             params: { present: 'true' }
        expect(response).to have_http_status(:not_found)
        expect(other_player.training_presences.find_by(training:)).to be_nil
      end
    end
  end

  describe 'POST create' do
    subject(:do_request) do
      post section_user_training_training_presences_path(section_id: section.to_param, user_id: coach.id, training_id: training.id)
    end

    context 'when the training belongs to the current section' do
      it 'marks the current user present' do
        do_request
        expect(coach.present_for?(training)).to be(true)
      end
    end

    context 'when the training belongs to another section' do
      let(:other_training) { create(:training, sections: [create(:section)]) }

      it 'returns not_found' do
        post section_user_training_training_presences_path(section_id: section.to_param, user_id: coach.id, training_id: other_training.id)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
