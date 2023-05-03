# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interceptors::BlockedAddressInterceptor do
  describe '.delivering_email' do
    before { described_class.delivering_email(message) }

    context 'when the email is sent to a blocked address' do
      let(:message) { Mail.new(to: 'jeanbaptisteeve577@gmail.com' ) }

      it { expect(message.perform_deliveries).to be false }
    end

    context 'when the email is sent to a non-blocked address' do
      let(:message) { Mail.new(to: 'test@exemple.com') }

      it { expect(message.perform_deliveries).to be true }
    end
  end
end