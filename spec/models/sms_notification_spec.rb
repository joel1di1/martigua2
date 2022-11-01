# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmsNotification do
  it { is_expected.to belong_to :section }

  describe '.create' do
    let(:section) { create(:section) }
    let!(:users) do
      (2..10).to_a.sample.times do
        section.add_player!(create(:user, with_section: section))
      end
    end

    it 'calls SendSmsJob' do
      section.players.each do |user|
        expect(SendSmsJob).to receive(:perform_later).with(kind_of(described_class), user)
      end
      create(:sms_notification, section:)
    end
  end
end
