# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DutyTasksController do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }
  let(:duty_task) { create(:duty_task, user:, club: section.club) }
  let(:duty_task_attributes) { attributes_for(:duty_task).merge(user_id: user.id, club_id: section.club.id) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    before { [duty_task] }

    it 'assigns all duty tasks as @duty_tasks' do
      get :index, params: { section_id: section.to_param }
      expect(assigns(:duty_tasks)).to eq([duty_task])
    end
  end

  describe 'GET #new' do
    it 'assigns a new duty task as @duty_task' do
      get :new, params: { section_id: section.to_param }
      expect(assigns(:duty_task)).to be_a_new(DutyTask)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new DutyTask' do
        expect do
          post :create, params: { section_id: section.to_param, duty_task: duty_task_attributes }
        end.to change(DutyTask, :count).by(1)
      end

      it 'redirects to the created duty task' do
        post :create, params: { section_id: section.to_param, duty_task: duty_task_attributes }
        expect(response).to redirect_to(section_duty_tasks_path)
      end
    end

    context 'with invalid params' do
      it 're-renders the "new" template' do
        post :create, params: { section_id: section.to_param, duty_task: duty_task_attributes.merge(key: nil) }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PUT #update' do
    let(:new_attributes) { { key: :mark_table } }

    context 'with valid params' do
      it 'updates the requested duty task' do
        put :update, params: { section_id: section.to_param, id: duty_task.to_param, duty_task: new_attributes }
        duty_task.reload
        expect(duty_task.key).to eq('mark_table')
      end

      it 'redirects to the duty task' do
        put :update, params: { section_id: section.to_param, id: duty_task.to_param, duty_task: new_attributes }
        expect(response).to redirect_to(section_duty_tasks_path(section))
      end
    end

    context 'with invalid params' do
      it 'does not update the duty task' do
        put :update, params: { section_id: section.to_param, id: duty_task.to_param, duty_task: { key: nil } }
        duty_task.reload
        expect(duty_task.key).not_to be_nil
      end

      it 're-renders the "edit" template' do
        put :update, params: { section_id: section.to_param, id: duty_task.to_param, duty_task: { key: nil } }
        expect(response).to render_template('edit')
      end
    end
  end
end
