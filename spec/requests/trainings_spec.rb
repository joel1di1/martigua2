# frozen_string_literal: true

require 'rails_helper'

describe 'Trainings' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }
  let(:coach) { create(:user, with_section_as_coach: section) }
  let(:training) { create(:training, with_section: section) }

  # Common path helpers
  let(:section_path_param) { { section_id: section.to_param } }
  let(:training_path_param) { { id: training.to_param } }

  describe 'GET index' do
    subject(:request) { get section_trainings_path(section_path_param.merge(page: 1)) }

    context 'when signed in as user' do
      before do
        sign_in user, scope: :user

        # Create trainings directly in the before block instead of using let!
        create(:training, :futur, with_section: section)
        create(:training, :futur, with_section: section, location: nil)
        create(:training, :futur) # training not in section

        request
      end

      it { expect(response).to have_http_status(:success) }
    end
  end

  describe 'GET edit' do
    subject(:request) { get edit_section_training_path(section_path_param.merge(training_path_param)) }

    context 'with existing training' do
      before do
        sign_in user
        request
      end

      it { expect(response).to have_http_status(:success) }
    end
  end

  describe 'PATCH update' do
    subject(:request) do
      patch(
        section_training_path(section_path_param.merge(training_path_param)),
        params: { training: training.attributes }
      )
    end

    context 'with existing training' do
      before { sign_in user, scope: :user }

      it { is_expected.to redirect_to(section_training_path(section_path_param.merge(training_path_param))) }
    end
  end

  describe 'POST create' do
    let(:new_training) { build(:training) }
    let(:training_params) { { training: new_training.attributes.slice('start_datetime', 'end_datetime') } }
    let(:create_request) { post section_trainings_path(section_path_param), params: training_params }

    context 'when signed in as user' do
      before { sign_in user, scope: :user }

      it 'creates a new training' do
        expect { create_request }.to change { section.trainings.count }.by(1)
      end

      it 'redirects to trainings index' do
        create_request
        expect(response).to redirect_to(section_trainings_path(section_path_param))
      end
    end
  end

  describe 'POST invitations' do
    subject(:request) { post invitations_section_training_path(section_path_param.merge(training_path_param)) }

    before { sign_in coach, scope: :user }

    it { is_expected.to redirect_to(section_trainings_path(section_path_param)) }
  end

  describe 'POST cancellation' do
    subject(:request) do
      post cancellation_section_training_path(section_path_param.merge(training_path_param)),
           params: { cancellation: { reason: 'TEST' } }
    end

    before { sign_in coach, scope: :user }

    it { is_expected.to redirect_to(section_training_path(section_path_param.merge(training_path_param))) }

    it 'marks the training as cancelled' do
      request
      expect(training.reload).to be_cancelled
    end
  end

  describe 'DELETE cancellation' do
    subject(:request) { delete uncancel_section_training_path(section_path_param.merge(training_path_param)) }

    before do
      training.cancel!(reason: 'for some reason')
      sign_in coach, scope: :user
    end

    it 'marks the training as not cancelled' do
      request
      expect(training.reload).not_to be_cancelled
    end

    it { is_expected.to redirect_to(section_training_path(section_path_param.merge(training_path_param))) }
  end
end
