# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlockedAddress do
  let(:email) { Faker::Internet.email }

  describe '.block!' do
    it { expect { BlockedAddress.block!(email) }.to change(BlockedAddress, :count).by(1) }

    context 'when email is already blocked' do
      before { create(:blocked_address, email:) }

      it { expect { BlockedAddress.block!(email) }.not_to change(BlockedAddress, :count) }
    end
  end

  describe '.unblock!' do
    before { create(:blocked_address, email:) }

    it { expect { BlockedAddress.unblock!(email) }.to change(BlockedAddress, :count).by(-1) }

    context 'when email is not blocked' do
      it { expect { BlockedAddress.unblock!('not_exist@example.com') }.not_to change(BlockedAddress, :count) }
    end
  end

  describe '.blocked?' do
    context 'when email is blocked' do
      before { create(:blocked_address, email:) }

      it { expect(BlockedAddress).to be_blocked(email) }
    end

    context 'when email is not blocked' do
      it { expect(BlockedAddress).not_to be_blocked(email) }
    end
  end
end
