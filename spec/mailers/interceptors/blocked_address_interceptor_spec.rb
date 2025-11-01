# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interceptors::BlockedAddressInterceptor do
  let(:email) { Faker::Internet.email }

  describe '.delivering_email' do
    let(:message) { Mail.new(to: email) }

    context 'when the email is sent to a blocked address' do
      before do
        BlockedAddress.block!(email)
        Interceptors::BlockedAddressInterceptor.delivering_email(message)
      end

      it { expect(message.perform_deliveries).to be false }
    end

    context 'when the email is sent to a non-blocked address' do
      before { Interceptors::BlockedAddressInterceptor.delivering_email(message) }

      it { expect(message.perform_deliveries).to be true }
    end

    context 'with a wildcard blocked domain' do
      let(:email) { Faker::Internet.email(domain: 'example.com') }

      before do
        BlockedAddress.block!('*@example.com')
        Interceptors::BlockedAddressInterceptor.delivering_email(message)
      end

      it { expect(message.perform_deliveries).to be false }
    end
  end
end
