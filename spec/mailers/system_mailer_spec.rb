# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SystemMailer do
  describe '#configuration_test' do
    let(:mail) { SystemMailer.configuration_test('admin@martigua.org') }

    it 'is sent from the default address to the given recipient' do
      expect(mail.to).to eq ['admin@martigua.org']
      expect(mail.from).to eq ['admin@martigua.org']
    end

    it 'names the environment in the subject' do
      expect(mail.subject).to eq "[martigua] Test de configuration email (#{Rails.env})"
    end

    it 'reports the delivery method in the body' do
      expect(mail.body.encoded).to match(Rails.application.config.action_mailer.delivery_method.to_s)
    end
  end
end
