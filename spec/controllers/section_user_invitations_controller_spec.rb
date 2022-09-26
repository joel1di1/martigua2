# frozen_string_literal: true

require 'rails_helper'

describe SectionUserInvitationsController, type: :controller do
  describe 'POST create' do
    subject { post :create, params: request_params }

    let(:invited_user) { build :user }
    let(:invitation_params) do
      { section_user_invitation: { email: invited_user.email,
                                   roles: [Participation::PLAYER, Participation::COACH].sample } }
    end

    context 'within section' do
      let(:section) { create :section }
      let(:request_params) { { section_id: section.to_param }.merge(invitation_params) }

      context 'signed as coach' do
        let(:user) { create :user }

        before do
          section.add_coach!(user)
          sign_in user
        end

        it { expect { subject }.to change(SectionUserInvitation, :count).by(1) }
        it { expect(subject).to redirect_to(new_section_section_user_invitation_path(section_id: section.to_param)) }
      end
    end
  end
end
