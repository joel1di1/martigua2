# frozen_string_literal: true

require 'rails_helper'

describe 'UserMerges' do
  let(:section) { create(:section) }
  let(:admin) { create(:user) }
  let(:parent) { create(:user, email: 'maman@example.com', with_section: section) }
  let(:child) { create(:user, with_section: section) }
  let(:params) { { user_merge: { source_id: parent.id, target_id: child.id, label: 'Maman' } } }

  before { create(:admin_user, email: admin.email) }

  context 'when signed in as an admin' do
    before { sign_in(admin, scope: :user) }

    it 'shows the merge form' do
      get new_user_merge_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Fusionner un compte parent'
    end

    it 'moves the parent address onto the child and deletes the parent' do
      params

      expect { post user_merges_path, params: }.to change(User, :count).by(-1)

      expect(child.reload.contact_email_addresses).to eq ['maman@example.com']
      expect(child.contact_emails.first.label).to eq 'Maman'
      expect(User.exists?(parent.id)).to be false
    end

    it 'reports a merge of an account into itself' do
      post user_merges_path, params: { user_merge: { source_id: parent.id, target_id: parent.id, label: '' } }

      expect(User.exists?(parent.id)).to be true
      expect(flash[:alert]).to be_present
    end
  end

  context 'when signed in as a regular user' do
    before { sign_in(child, scope: :user) }

    it 'forbids the form' do
      get new_user_merge_path

      expect(response).to have_http_status(:forbidden)
    end

    it 'forbids the merge' do
      params

      expect { post user_merges_path, params: }.not_to change(User, :count)
      expect(response).to have_http_status(:forbidden)
    end
  end

  context 'when signed out' do
    it 'redirects to the sign in page' do
      get new_user_merge_path

      expect(response).to redirect_to new_user_session_path
    end
  end
end
