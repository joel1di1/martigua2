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
      get new_section_user_merge_path(section)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Fusionner un compte parent'
    end

    it 'only offers this season members of the section' do
      other_section_user = create(:user, with_section: create(:section))
      last_season_user = create(:user, email: 'lastseason@example.com')
      past_season = create(:season, start_date: 3.years.ago, end_date: 2.years.ago)
      create(:participation, user: last_season_user, section:, season: past_season)
      parent

      get new_section_user_merge_path(section)

      expect(response.body).to include parent.email
      expect(response.body).not_to include other_section_user.email
      expect(response.body).not_to include last_season_user.email
    end

    it 'moves the parent address onto the child and deletes the parent' do
      params

      expect { post section_user_merges_path(section), params: }.to change(User, :count).by(-1)

      expect(child.reload.contact_email_addresses).to eq ['maman@example.com']
      expect(child.contact_emails.first.label).to eq 'Maman'
      expect(User.exists?(parent.id)).to be false
    end

    it 'refuses an account outside the section' do
      outsider = create(:user, with_section: create(:section))
      child

      expect do
        post section_user_merges_path(section),
             params: { user_merge: { source_id: outsider.id, target_id: child.id, label: '' } }
      end.not_to change(User, :count)
      expect(flash[:alert]).to eq 'Compte introuvable dans cette section'
    end

    it 'reports a merge of an account into itself' do
      post section_user_merges_path(section),
           params: { user_merge: { source_id: parent.id, target_id: parent.id, label: '' } }

      expect(User.exists?(parent.id)).to be true
      expect(flash[:alert]).to be_present
    end
  end

  context 'when signed in as a coach of the section' do
    let(:coach) { create(:user, with_section_as_coach: section) }

    before { sign_in(coach, scope: :user) }

    it 'shows the merge form' do
      get new_section_user_merge_path(section)

      expect(response).to have_http_status(:ok)
    end

    it 'merges' do
      params

      expect { post section_user_merges_path(section), params: }.to change(User, :count).by(-1)
      expect(child.reload.contact_email_addresses).to eq ['maman@example.com']
    end
  end

  context 'when signed in as a coach of another section' do
    let(:other_coach) { create(:user, with_section_as_coach: create(:section)) }

    before { sign_in(other_coach, scope: :user) }

    it 'forbids the form' do
      get new_section_user_merge_path(section)

      expect(response).to have_http_status(:forbidden)
    end
  end

  context 'when signed in as a player of the section' do
    before { sign_in(child, scope: :user) }

    it 'forbids the form' do
      get new_section_user_merge_path(section)

      expect(response).to have_http_status(:forbidden)
    end

    it 'forbids the merge' do
      params

      expect { post section_user_merges_path(section), params: }.not_to change(User, :count)
      expect(response).to have_http_status(:forbidden)
    end
  end

  context 'when signed out' do
    it 'redirects to the sign in page' do
      get new_section_user_merge_path(section)

      expect(response).to redirect_to new_user_session_path
    end
  end
end
