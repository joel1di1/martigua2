# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interceptors::BlockedAddressInterceptor do
  let(:email) { Faker::Internet.email }

  describe '.delivering_email' do
    let(:message) { Mail.new(to: email) }

    context 'when the email is sent to a blocked address' do
      before do
        BlockedAddress.block!(email)
        described_class.delivering_email(message)
      end

      it { expect(message.perform_deliveries).to be false }
    end

    context 'when the email is sent to a non-blocked address' do
      before { described_class.delivering_email(message) }

      it { expect(message.perform_deliveries).to be true }
    end
  end
end
