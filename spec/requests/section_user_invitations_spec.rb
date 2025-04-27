# frozen_string_literal: true

require 'rails_helper'

describe 'Section User Invitations' do
  describe 'POST create' do
    subject(:do_post) do
      post section_section_user_invitations_path(section_id: section.to_param), params: invitation_params
    end

    let(:invited_user) { build(:user) }
    let(:invitation_params) do
      { section_user_invitation: { email: invited_user.email,
                                   roles: [Participation::PLAYER, Participation::COACH].sample } }
    end

    let(:section) { create(:section) }

    context 'when signed as coach' do
      let(:user) { create(:user) }

      before do
        section.add_coach!(user)
        sign_in user, scope: :user
      end

      it { expect { do_post }.to change(SectionUserInvitation, :count).by(1) }
      it { expect(do_post).to redirect_to(new_section_section_user_invitation_path(section_id: section.to_param)) }
    end
  end
end
