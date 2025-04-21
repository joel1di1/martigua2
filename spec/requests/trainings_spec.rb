# frozen_string_literal: true

require 'rails_helper'

describe 'Trainings' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }

  describe 'GET index' do
    let(:request) { get section_trainings_path(section_id: section.to_param, page: 1) }

    context 'within section' do
      context 'signed as user' do
        let(:user) { create(:user, with_section: section) }

        let!(:training1) { create(:training, :futur, with_section: section) }
        let!(:training2) { create(:training, :futur, with_section: section, location: nil) }
        let!(:training_not_in_section) { create(:training, :futur) }

        before do
          sign_in user, scope: :user
          [training1, training2, training_not_in_section]
          request
        end

        it { expect(response).to have_http_status(:success) }
      end
    end
  end

  describe 'GET edit' do
    let(:request) { get edit_section_training_path(section_id: section.to_param, id: training.id) }

    context 'with existing training' do
      let(:training) { create(:training, with_section: section) }

      before do
        sign_in user
        request
      end

      it { expect(response).to have_http_status(:success) }
    end
  end

  describe 'PATCH update' do
    context 'with existing training' do
      subject { patch section_training_path(section_id: section.to_param, id: training.to_param), params: { training: training.attributes } }

      let(:training) { create(:training, with_section: section) }

      before { sign_in user, scope: :user }

      it { expect(subject).to redirect_to(section_training_path(section_id: section.to_param, id: training.to_param)) }
    end
  end

  describe 'POST create' do
    let(:new_training) { build(:training) }

    context 'signed as user' do
      let(:training_params) { { training: new_training.attributes.slice('start_datetime', 'end_datetime') } }
      let(:request) { post section_trainings_path(section_id: section.id), params: training_params }

      before { sign_in user, scope: :user }

      describe 'effects' do
        it { expect { request }.to change { section.trainings.count }.by(1) }
      end

      describe 'response' do
        subject { post section_trainings_path(section_id: section.id), params: training_params }

        it { expect(subject).to redirect_to(section_trainings_path(section_id: section.to_param)) }
      end
    end
  end

  describe 'POST invitations' do
    subject { post invitations_section_training_path(section_id: section.to_param, id: training.to_param) }

    let(:section) { create(:section) }
    let(:coach) { create(:user, with_section_as_coach: section) }
    let(:training) { create(:training, with_section: section) }

    before { sign_in coach, scope: :user }

    it { expect(subject).to redirect_to(section_trainings_path(section_id: section.to_param)) }
  end

  describe 'POST cancellation' do
    subject do
      post cancellation_section_training_path(section_id: section.to_param, id: training.to_param), 
           params: { cancellation: { reason: 'TEST' } }
    end

    let(:section) { create(:section) }
    let(:coach) { create(:user, with_section_as_coach: section) }
    let(:training) { create(:training, with_section: section) }

    before { sign_in coach, scope: :user }

    it { expect(subject).to redirect_to(section_training_path(section_id: section.to_param, id: training.to_param)) }
    it { expect(subject && training.reload.cancelled?).to be_truthy }
  end

  describe 'DELETE cancellation' do
    subject { delete uncancel_section_training_path(section_id: section.to_param, id: training.to_param) }

    let(:section) { create(:section) }
    let(:coach) { create(:user, with_section_as_coach: section) }
    let(:training) { create(:training, with_section: section) }

    before do
      training.cancel!(reason: 'for some reason')
      sign_in coach
    end

    it { expect(subject && training.reload.cancelled?).to be_falsy }
    it { expect(subject).to redirect_to(section_training_path(section_id: section.to_param, id: training.to_param)) }
  end
end