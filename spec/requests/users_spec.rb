# frozen_string_literal: true

require 'rails_helper'

describe 'Users' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }

  describe 'GET index' do
    let(:request) { get section_users_path(section_id: section.to_param) }

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

  describe 'GET show' do
    let(:coach) { create(:user, with_section_as_coach: section) }

    before { sign_in coach, scope: :user }

    it 'succeeds for a user belonging to the current section' do
      get section_user_path(id: user.to_param, section_id: section.to_param)
      expect(response).to have_http_status(:success)
    end

    it 'returns not_found for a user belonging to another section' do
      other_user = create(:user, with_section: create(:section))
      get section_user_path(id: other_user.to_param, section_id: section.to_param)
      expect(response).to have_http_status(:not_found)
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

    context 'when in section' do
      let(:old_password) { user.password }

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

    context 'when not in section' do
      let(:old_password) { user.password }

      before do
        sign_in user, scope: :user
        patch user_path(id: user.to_param), params: { user: new_attributes }
      end

      it 'redirect_to user path' do
        expect(response).to redirect_to(user_path(user))
      end
    end

    context 'when the target user belongs to another section' do
      let(:coach) { create(:user, with_section_as_coach: section) }
      let(:other_user) { create(:user, with_section: create(:section)) }

      it 'returns not_found and does not update the user' do
        sign_in coach, scope: :user
        patch section_user_path(id: other_user.to_param, section_id: section.to_param),
              params: { user: new_attributes }
        expect(response).to have_http_status(:not_found)
        expect(other_user.reload.first_name).not_to eq(new_attributes[:first_name])
      end
    end
  end

  describe 'POST training_presences' do
    let(:training1) { create(:training, with_section: section) }
    let(:training2) { create(:training, with_section: section) }
    let(:training_full) { create(:training, with_section: section, max_capacity: 0) }

    let(:post_training_presences) do
      post training_presences_user_path(id: user.to_param), params: {
        user_token: user.generate_token_for(:email_authentication),
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

    context 'when the training belongs to another section' do
      let(:other_training) { create(:training, with_section: create(:section)) }

      let(:post_training_presences) do
        post training_presences_user_path(id: user.to_param), params: {
          user_token: user.generate_token_for(:email_authentication),
          present_ids: [other_training.id], checked_ids: [other_training.id]
        }
      end

      it 'does not set presence for the training' do
        expect(user.reload).not_to be_present_for(other_training)
      end
    end
  end

  describe 'POST match_availabilities' do
    let(:championship) { create(:championship) }
    let(:match) { create(:match, championship:) }
    let(:post_match_availabilities) do
      post match_availabilities_user_path(id: user.to_param), params: {
        user_token: user.generate_token_for(:email_authentication),
        present_ids: [match.id], checked_ids: [match.id]
      }
    end

    before { create(:team, with_section: section, enrolled_in: championship) }

    it 'sets availability for a match belonging to a section the user is a member of' do
      post_match_availabilities
      expect(user.reload.available_for?(match)).to be(true)
    end

    context 'when the match belongs to a championship the user has no section in' do
      let(:other_championship) { create(:championship) }
      let(:other_match) { create(:match, championship: other_championship) }

      let(:post_match_availabilities) do
        post match_availabilities_user_path(id: user.to_param), params: {
          user_token: user.generate_token_for(:email_authentication),
          present_ids: [other_match.id], checked_ids: [other_match.id]
        }
      end

      it 'does not create a match availability' do
        expect { post_match_availabilities }.not_to change(MatchAvailability, :count)
      end
    end
  end

  describe 'DELETE destroy user' do
    context 'when in section' do
      before { sign_in user, scope: :user }

      let(:do_request) { delete section_user_path(section_id: section.to_param, id: user.to_param) }

      it_behaves_like 'an endpoint denied to non-members of the section'

      it { expect { do_request }.to change { section.users.count }.by(-1) }

      describe 'response' do
        before { do_request }

        it { expect(response).to redirect_to(section_users_path(section)) }
      end
    end

    context 'when in section group' do
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

    context 'when the group belongs to another section' do
      let(:other_group) { create(:group, section: create(:section)) }
      let(:do_request) do
        delete section_group_user_path(section_id: section.to_param, group_id: other_group.to_param, id: user.to_param)
      end

      before do
        other_group.add_user! user
        sign_in user, scope: :user
      end

      it 'returns not_found and does not remove the user from the group' do
        do_request
        expect(response).to have_http_status(:not_found)
        expect(other_group.users.count).to eq(1)
      end
    end
  end
end
