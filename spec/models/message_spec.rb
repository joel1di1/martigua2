# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:channel) }
    it { is_expected.to belong_to(:parent_message).class_name('Message').optional }
    it { is_expected.to have_many(:child_messages).class_name('Message').dependent(:destroy) }
    # it { should have_many(:reactions).dependent(:destroy) }
  end

  describe 'creating a message' do
    let(:section) { create(:section) }
    let(:user) { create(:user, with_section: section) }
    let(:channel) { create(:channel, section:) }
    let(:parent_message) { create(:message, user:, channel:) }

    it 'creates a valid message' do
      message = build(:message, user:, channel:)
      expect(message).to be_valid
    end

    it 'creates a valid child message' do
      child_message = build(:message, user:, channel:, parent_message:)
      expect(child_message).to be_valid
    end

    context 'with another user' do
      let!(:other_user) { create(:user, with_section: section) }

      it 'expect notifications to be sent' do
        Sidekiq::Testing.inline! do
          # expect to have WebPushService called on send_notification_to_all_user_subscriptions
          expect(WebpushService).to receive(:send_notification_to_all_user_subscriptions).once

          create(:message, user:, channel:)
        end
      end
    end
  end
end
