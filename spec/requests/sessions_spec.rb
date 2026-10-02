# frozen_string_literal: true

require 'rails_helper'

describe 'Sessions' do
  let(:user) { create(:user, password: 'secret123') }
  let(:hint) { 'un lien de connexion vient de lui être envoyé' }

  def post_login(email, password = 'whatever')
    run_jobs_inline do
      post user_session_path, params: { user: { email:, password: } }
    end
  end

  describe 'POST create' do
    it 'signs a player in with the right password' do
      post_login(user.email, 'secret123')

      expect(controller.current_user).to eq user
    end

    it 'answers a wrong password without sending anything' do
      expect { post_login(user.email) }.not_to change(ActionMailer::Base.deliveries, :count)

      expect(response.body).to include(hint)
    end

    it 'shows the failure message inline on the login page, not as a fading toast' do
      post_login(user.email)

      expect(response.body).to include('role="alert"')
      expect(response.body).not_to include('data-controller="notification"')
    end

    context 'with a relative address' do
      before { create(:user_contact_email, user:, email: 'maman@example.com') }

      it 'sends a sign-in link and says the same as for a wrong password' do
        expect { post_login('maman@example.com') }.to change(ActionMailer::Base.deliveries, :count).by(1)

        expect(ActionMailer::Base.deliveries.last.to).to eq ['maman@example.com']
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to include(hint)
      end
    end

    context 'with a player who has not accepted the invitation yet' do
      let(:invited) { User.invite!(email: 'new@example.com', first_name: 'New', last_name: 'Player') { |u| u.skip_invitation = true } }

      it 'sends a sign-in link' do
        invited

        expect { post_login('new@example.com') }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end

    context 'with an unknown address' do
      it 'sends nothing and says the same' do
        expect { post_login('inconnu@example.com') }.not_to change(ActionMailer::Base.deliveries, :count)

        expect(response.body).to include(hint)
      end
    end
  end

  describe 'password reset with a relative address' do
    before { create(:user_contact_email, user:, email: 'maman@example.com') }

    it 'sends a sign-in link' do
      run_jobs_inline do
        expect { post user_password_path, params: { user: { email: 'maman@example.com' } } }
          .to change(ActionMailer::Base.deliveries, :count).by(1)
      end

      expect(ActionMailer::Base.deliveries.last.body.to_s).to include('user_token=')
    end
  end

  describe 'an expired link' do
    it 'sends the visitor to the login link page' do
      get root_path(user_token: 'expired')

      expect(response).to redirect_to(new_login_link_path)
      expect(flash[:alert]).to include('expiré')
    end
  end
end
