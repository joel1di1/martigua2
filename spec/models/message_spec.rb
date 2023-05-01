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

  describe 'validations' do
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:channel) }
  end

  describe 'creating a message' do
    let(:user) { create(:user) }
    let(:channel) { create(:channel) }
    let(:parent_message) { create(:message, user:, channel:) }

    it 'creates a valid message' do
      message = build(:message, user:, channel:)
      expect(message).to be_valid
    end

    it 'creates a valid child message' do
      child_message = build(:message, user:, channel:, parent_message:)
      expect(child_message).to be_valid
    end
  end
end
