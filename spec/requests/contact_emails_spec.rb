# frozen_string_literal: true

require 'rails_helper'

describe 'ContactEmails' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }
  let(:params) { { user_contact_email: { email: 'maman@example.com', label: 'Maman' } } }

  describe 'POST create' do
    context 'when the player adds their own relative' do
      before { sign_in(user, scope: :user) }

      it 'creates the contact email' do
        expect { post section_user_contact_emails_path(section, user), params: }
          .to change(user.contact_emails, :count).by(1)
        expect(user.contact_email_addresses).to eq ['maman@example.com']
      end
    end

    context 'when a coach of the section adds it for a player' do
      let(:coach) { create(:user, with_section_as_coach: section) }

      before { sign_in(coach, scope: :user) }

      it 'creates the contact email' do
        expect { post section_user_contact_emails_path(section, user), params: }
          .to change(user.contact_emails, :count).by(1)
      end
    end

    context 'when another player of the section tries' do
      let(:other_player) { create(:user, with_section: section) }

      before { sign_in(other_player, scope: :user) }

      it 'is forbidden' do
        expect { post section_user_contact_emails_path(section, user), params: }
          .not_to change(UserContactEmail, :count)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with an invalid address' do
      before { sign_in(user, scope: :user) }

      it 'does not create it' do
        expect do
          post section_user_contact_emails_path(section, user),
               params: { user_contact_email: { email: 'not-an-email' } }
        end.not_to change(UserContactEmail, :count)
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:contact_email) { create(:user_contact_email, user:) }

    context 'when the player removes their own relative' do
      before { sign_in(user, scope: :user) }

      it 'destroys it' do
        expect { delete section_user_contact_email_path(section, user, contact_email) }
          .to change(user.contact_emails, :count).by(-1)
      end
    end

    context 'when another player of the section tries' do
      let(:other_player) { create(:user, with_section: section) }

      before { sign_in(other_player, scope: :user) }

      it 'is forbidden' do
        expect { delete section_user_contact_email_path(section, user, contact_email) }
          .not_to change(UserContactEmail, :count)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the contact email belongs to another user' do
      let(:other_contact_email) { create(:user_contact_email, user: create(:user)) }

      before { sign_in(user, scope: :user) }

      it 'is not found' do
        delete section_user_contact_email_path(section, user, other_contact_email)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
