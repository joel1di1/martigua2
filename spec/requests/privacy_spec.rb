# frozen_string_literal: true

require 'rails_helper'

describe 'Privacy (RGPD)' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section, password: 'secret123') }

  it 'shows the privacy page to anonymous visitors, linked from the login page' do
    get root_path
    expect(response.body).to include(privacy_path)

    get privacy_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('admin@martigua.org')
  end

  it 'lets a member delete their own account and its data' do
    create(:absence, user:)
    sign_in user, scope: :user

    get edit_user_path(user)
    expect(response.body).to include('Supprimer mon compte')

    expect { delete user_registration_path }.to change(User, :count).by(-1).and change(Absence, :count).by(-1)
    expect(response).to redirect_to(root_path)
  end

  it 'does not offer the deletion of someone else account' do
    coach = create(:user, with_section_as_coach: section)
    sign_in coach, scope: :user

    get edit_section_user_path(user, section_id: section.to_param)
    expect(response.body).not_to include('Supprimer mon compte')
  end

  it 'does not store the sign-in IP' do
    post user_session_path, params: { user: { email: user.email, password: 'secret123' } }

    expect(user.reload).to have_attributes(sign_in_count: 1, current_sign_in_ip: nil, last_sign_in_ip: nil)
  end
end
