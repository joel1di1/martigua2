# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MartiguaDeviseMailer do
  let(:user) { create(:user) }

  it 'is the configured devise mailer' do
    expect(Devise.mailer).to eq MartiguaDeviseMailer
  end

  describe 'reset password instructions' do
    let(:mail) { MartiguaDeviseMailer.reset_password_instructions(user, 'faketoken') }

    it 'is sent to the user only when there is no relative' do
      expect(mail.to).to eq [user.email]
      expect(mail.cc).to be_nil
    end

    it 'copies the relatives' do
      create(:user_contact_email, user:, email: 'maman@example.com')

      expect(mail.to).to eq [user.email]
      expect(mail.cc).to eq ['maman@example.com']
    end
  end

  describe 'invitation instructions' do
    let(:mail) { MartiguaDeviseMailer.invitation_instructions(user, 'faketoken') }

    it 'copies the relatives' do
      create(:user_contact_email, user:, email: 'maman@example.com')

      expect(mail.cc).to eq ['maman@example.com']
    end
  end
end
