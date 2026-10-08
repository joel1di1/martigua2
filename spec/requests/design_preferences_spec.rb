# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Design preference' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }

  before { sign_in user, scope: :user }

  describe 'PATCH /design_preference' do
    it 'enables the new design and redirects back' do
      patch design_preference_path, params: { new_design: '1' }, headers: { 'HTTP_REFERER' => section_groups_url(section) }

      expect(user.reload).to be_new_design
      expect(response).to redirect_to(section_groups_url(section))
    end

    it 'disables the new design' do
      user.update!(new_design: true)

      patch design_preference_path, params: { new_design: '0' }

      expect(user.reload).not_to be_new_design
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'groups pages' do
    it 'renders the legacy design by default' do
      get section_groups_path(section)

      expect(response.body).to include('new-design-banner')
      expect(response.body).not_to include('id="sidebar"')
    end

    it 'renders the new design for users who opted in' do
      user.update!(new_design: true)

      get section_groups_path(section)

      expect(response.body).not_to include('new-design-banner')
      expect(response.body).to include('id="sidebar"')
    end

    it 'keeps serving json whatever the design' do
      user.update!(new_design: true)
      group = create(:group, section:)

      get section_group_path(section, group, format: :json)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq 'application/json'
    end
  end

  describe 'profile' do
    it 'shows the design toggle on the user own profile' do
      get edit_section_user_path(section, user)

      expect(response.body).to include('design-preference')
    end

    it 'does not show the design toggle when editing someone else' do
      coach = create(:user, with_section_as_coach: section)
      sign_in coach, scope: :user

      get edit_section_user_path(section, user)

      expect(response.body).not_to include('design-preference')
    end
  end
end
