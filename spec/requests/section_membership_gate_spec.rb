# frozen_string_literal: true

require 'rails_helper'

describe 'Section membership gate' do
  let(:section) { create(:section) }

  describe 'GET section' do
    let(:do_request) { get section_path(section) }

    it_behaves_like 'an endpoint denied to non-members of the section'

    context 'when signed in as a member of the section' do
      let(:member) { create(:user, with_section: section) }

      before do
        sign_in member, scope: :user
        do_request
      end

      it { expect(response).to have_http_status(:success) }
    end

    context 'when signed in as an admin of the club' do
      let(:club_admin) { create(:user) }

      before do
        create(:club_admin_role, user: club_admin, club: section.club)
        sign_in club_admin, scope: :user
        do_request
      end

      it { expect(response).to have_http_status(:success) }
    end
  end

  describe 'a nested section resource' do
    let(:do_request) { get section_trainings_path(section) }

    it_behaves_like 'an endpoint denied to non-members of the section'
  end

  describe 'a nested write endpoint' do
    let(:championship) { create(:championship) }
    let(:do_request) do
      patch section_championship_path(section, championship), params: { championship: { name: 'hacked' } }
    end

    it_behaves_like 'an endpoint denied to non-members of the section'

    it 'does not modify the record' do
      sign_in create(:user, with_section: create(:section)), scope: :user
      expect { do_request }.not_to(change { championship.reload.name })
    end
  end
end
