# frozen_string_literal: true

require 'rails_helper'

describe 'LoginLinks' do
  let(:notice) { 'Si cette adresse est connue, un lien de connexion vient de vous être envoyé.' }

  def post_login_link(email)
    Sidekiq::Testing.inline! do
      post login_link_path, params: { email: }
    end
  end

  describe 'GET new' do
    it 'is reachable without being signed in' do
      get new_login_link_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Recevoir un lien de connexion')
    end
  end

  describe 'POST create' do
    context 'with a main email' do
      let(:user) { create(:user) }

      it 'sends one link to that address' do
        expect { post_login_link(user.email) }.to change(ActionMailer::Base.deliveries, :count).by(1)
        expect(ActionMailer::Base.deliveries.last.to).to eq [user.email]
      end
    end

    context 'with a contact email' do
      let(:user) { create(:user) }

      before { create(:user_contact_email, user:, email: 'maman@example.com') }

      it 'sends the link to the relative, for that player' do
        expect { post_login_link('maman@example.com') }.to change(ActionMailer::Base.deliveries, :count).by(1)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq ['maman@example.com']
        expect(mail.subject).to include(user.short_name)
        expect(mail.body.to_s).to include('user_token=')
      end

      it 'matches case-insensitively' do
        expect { post_login_link(' MAMAN@Example.com ') }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end

    context 'when a parent has two children in the club' do
      before do
        create(:user_contact_email, user: create(:user), email: 'maman@example.com')
        create(:user_contact_email, user: create(:user), email: 'maman@example.com')
      end

      it 'sends one link per child' do
        expect { post_login_link('maman@example.com') }.to change(ActionMailer::Base.deliveries, :count).by(2)
      end
    end

    context 'with an unknown address' do
      it 'sends nothing but answers the same thing' do
        expect { post_login_link('inconnu@example.com') }.not_to change(ActionMailer::Base.deliveries, :count)

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:notice]).to eq notice
      end
    end

    context 'with a blank address' do
      it 'sends nothing' do
        expect { post_login_link('') }.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end

    it 'answers identically for a known address, so addresses cannot be probed' do
      post_login_link(create(:user).email)

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:notice]).to eq notice
    end
  end

  describe 'the emailed link' do
    let(:user) { create(:user) }

    it 'signs the visitor in as the player' do
      create(:user_contact_email, user:, email: 'maman@example.com')
      post_login_link('maman@example.com')

      token = ActionMailer::Base.deliveries.last.body.to_s[/user_token=([^"&]+)/, 1]
      get root_path(user_token: CGI.unescape(token))

      expect(response).to have_http_status(:success)
      expect(controller.current_user).to eq user
    end
  end
end
