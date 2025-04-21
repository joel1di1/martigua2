# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Groups' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }
  let(:group) { create(:group, section:) }

  before do
    sign_in user
  end

  describe 'POST /sections/:section_id/groups/:group_id/add_users' do
    let(:do_request) do
      post section_group_add_users_path(section, group), params: { user_id: user.id }
    end

    it 'adds a user to the group' do
      expect { do_request }.to change { group.reload.users.count }.by(1)
    end

    it 'redirects to the group page' do
      do_request
      expect(response).to redirect_to(section_group_path(section, group))
    end
  end

  describe 'POST /sections/:section_id/groups' do
    context 'with valid attributes' do
      let(:new_group_attributes) { attributes_for(:group) }

      it 'creates a new group' do
        expect do
          post section_groups_path(section), params: { group: new_group_attributes }
        end.to change(Group, :count).by(1)
      end

      it 'redirects to the new group' do
        post section_groups_path(section), params: { group: new_group_attributes }
        expect(response).to redirect_to(section_group_path(section, Group.last))
      end
    end

    context 'with invalid attributes' do
      let(:new_group_attributes) { attributes_for(:group, name: nil) }

      it 'does not create a new group' do
        expect do
          post section_groups_path(section), params: { group: new_group_attributes }
        end.not_to change(Group, :count)
      end

      it 'returns unprocessable entity status' do
        post section_groups_path(section), params: { group: new_group_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
