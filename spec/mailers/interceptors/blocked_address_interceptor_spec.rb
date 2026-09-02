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

    context 'when the blocked address is the only recipient but relatives are in copy' do
      let(:message) { Mail.new(to: email, cc: 'maman@example.com') }

      before do
        BlockedAddress.block!(email)
        Interceptors::BlockedAddressInterceptor.delivering_email(message)
      end

      it 'still delivers to the relatives' do
        expect(message.perform_deliveries).to be true
        expect(message.to).to be_blank
        expect(message.cc).to eq ['maman@example.com']
      end
    end

    context 'when every recipient is blocked' do
      let(:message) { Mail.new(to: email, cc: 'maman@example.com') }

      before do
        BlockedAddress.block!(email)
        BlockedAddress.block!('maman@example.com')
        Interceptors::BlockedAddressInterceptor.delivering_email(message)
      end

      it { expect(message.perform_deliveries).to be false }
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
