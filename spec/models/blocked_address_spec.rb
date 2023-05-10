# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlockedAddress do
  let(:email) { Faker::Internet.email }

  describe '.block!' do
    it { expect { described_class.block!(email) }.to change(described_class, :count).by(1) }

    context 'when email is already blocked' do
      before { create(:blocked_address, email:) }

      it { expect { described_class.block!(email) }.not_to change(described_class, :count) }
    end
  end

  describe '.unblock!' do
    before { create(:blocked_address, email:) }

    it { expect { described_class.unblock!(email) }.to change(described_class, :count).by(-1) }

    context 'when email is not blocked' do
      it { expect { described_class.unblock!('not_exist@example.com') }.not_to change(described_class, :count) }
    end
  end

  describe '.blocked?' do
    context 'when email is blocked' do
      before { create(:blocked_address, email:) }

      it { expect(described_class).to be_blocked(email) }
    end

    context 'when email is not blocked' do
      it { expect(described_class).not_to be_blocked(email) }
    end
  end
end
