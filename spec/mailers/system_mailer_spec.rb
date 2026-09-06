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

  describe '.deliver_configuration_test!' do
    let(:delivery) { instance_double(Scaleway::TransactionalEmailDelivery) }
    let(:delivered) { [] }

    before do
      allow(delivery).to receive(:deliver!) { |mail| delivered << mail }
      allow(Scaleway::TransactionalEmailDelivery).to receive(:new).and_return(delivery)
    end

    it 'delivers through Scaleway even when the environment configures another method' do
      mail = SystemMailer.deliver_configuration_test!('coach@martigua.org')

      expect(delivered).to eq [mail]
      expect(mail.raise_delivery_errors).to be true
    end

    it 'lets a delivery error through instead of swallowing it' do
      allow(delivery).to receive(:deliver!).and_raise(Scaleway::TransactionalEmailDelivery::DeliveryError, 'nope')

      expect { SystemMailer.deliver_configuration_test!('coach@martigua.org') }
        .to raise_error(Scaleway::TransactionalEmailDelivery::DeliveryError, 'nope')
    end

    it 'reports a recipient the interceptor blocked as not delivered' do
      create(:blocked_address, email: 'coach@martigua.org')

      mail = SystemMailer.deliver_configuration_test!('coach@martigua.org')

      expect(delivered).to be_empty
      expect(mail.to).to be_blank
    end
  end
end
