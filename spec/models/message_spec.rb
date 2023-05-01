# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:channel) }
    it { should belong_to(:parent_message).class_name('Message').optional }
    it { should have_many(:child_messages).class_name('Message').dependent(:destroy) }
    # it { should have_many(:reactions).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:channel) }
  end

  describe 'creating a message' do
    let(:user) { create(:user) }
    let(:channel) { create(:channel) }
    let(:parent_message) { create(:message, user: user, channel: channel) }

    it 'creates a valid message' do
      message = build(:message, user: user, channel: channel)
      expect(message).to be_valid
    end

    it 'creates a valid child message' do
      child_message = build(:message, user: user, channel: channel, parent_message: parent_message)
      expect(child_message).to be_valid
    end
  end
end
