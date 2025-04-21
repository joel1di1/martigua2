# frozen_string_literal: true

require 'rails_helper'

describe 'Users' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }

  describe 'GET index' do
    let(:request) { get section_users_path(section_id: section.to_param) }

    context 'within section' do
      context 'with one user' do
        before { sign_in(user, scope: :user) && request }

        it { expect(response).to have_http_status(:success) }
      end

      context 'with one user with several roles' do
        let(:user) do
          user = create(:user, with_section_as_coach: section)
          section.add_player! user
          user
        end

        before { sign_in(user, scope: :user) && request }

        it { expect(response).to have_http_status(:success) }
      end
    end
  end

  describe 'GET edit' do
    it 'shows edit form' do
      sign_in user, scope: :user
      get edit_section_user_path(id: user.to_param, section_id: section.to_param)

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH update' do
    let(:new_attributes) { attributes_for(:user).except(:password) }

    context 'within section' do
      let!(:old_password) { user.password }

      before do
        sign_in user, scope: :user
        patch section_user_path(id: user.to_param, section_id: section.to_param), 
              params: { user: new_attributes, player: 'player' }
        user.reload
      end

      it 'updates user' do
        expect(user.first_name).to eq new_attributes[:first_name]
        expect(user.last_name).to eq new_attributes[:last_name]
        expect(user.nickname).to eq new_attributes[:nickname]
        expect(user.phone_number).to eq new_attributes[:phone_number]
        expect(user.email).to eq new_attributes[:email]
        expect(user.valid_password?(old_password)).to be true
      end

      it 'redirect_to section user path' do
        expect(response).to redirect_to(section_user_path(user, section_id: section.to_param))
      end
    end

    context 'within no section' do
      let!(:old_password) { user.password }

      before do
        sign_in user, scope: :user
        patch user_path(id: user.to_param), params: { user: new_attributes }
      end

      it 'redirect_to user path' do
        expect(response).to redirect_to(user_path(user))
      end
    end
  end

  describe 'POST training_presences' do
    let(:training1) { create(:training) }
    let(:training2) { create(:training) }
    let(:training_full) { create(:training, max_capacity: 0) }

    let(:post_training_presences) do
      post training_presences_user_path(id: user.to_param), params: {
        user_email: user.email, user_token: user.authentication_token,
        present_ids: [training1.id, training2.id, training_full.id], checked_ids: [training1.id, training_full.id]
      }
    end

    before { post_training_presences }

    it 'updates training presences' do
      expect(user.reload).to be_present_for(training1)
      expect(user.reload).not_to be_present_for(training2)
      expect(user.reload).not_to be_present_for(training_full)
    end

    it { expect(response).to redirect_to(root_path) }
  end

  describe 'DELETE destroy user' do
    context 'from section' do
      before { sign_in user, scope: :user }

      let(:do_request) { delete section_user_path(section_id: section.to_param, id: user.to_param) }

      it { expect { do_request }.to change { section.users.count }.by(-1) }

      describe 'response' do
        before { do_request }

        it { expect(response).to redirect_to(section_users_path(section)) }
      end
    end

    context 'from section group' do
      let(:group) { create(:group, section:) }
      let(:do_request) do
        delete section_group_user_path(section_id: section.to_param, group_id: group.to_param, id: user.to_param)
      end

      before do
        group.add_user! user
        sign_in user, scope: :user
      end

      it { expect { do_request }.not_to(change { section.users.count }) }
      it { expect { do_request }.to(change { group.users.count }.by(-1)) }

      describe 'response' do
        before { do_request }

        it { expect(response).to redirect_to(section_group_path(section, group)) }
      end
    end
  end
end