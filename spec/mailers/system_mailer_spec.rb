# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SystemMailer do
  describe '#solid_check' do
    let(:user) { create(:user) }
    let(:mail) { SystemMailer.solid_check(user) }

    it 'is sent to the given user' do
      expect(mail.to).to eq [user.email]
    end

    it 'names the environment in the subject' do
      expect(mail.subject).to include("[martigua] Vérification Solid Queue (#{Rails.env}")
    end

    it 'reports the delivery method in the body' do
      expect(mail.body.encoded).to match(Rails.application.config.action_mailer.delivery_method.to_s)
    end
  end
end
