# frozen_string_literal: true

require 'rails_helper'

describe MessagesController do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }
  let(:championship) { create(:championship) }

  before do
    sign_in user
  end

  describe 'POST mark_as_read' do
    let!(:message) { create(:message, channel: section.general_channel) }

    it 'mark message as read' do
      expect(user.read?(message)).to be_falsey

      post :mark_as_read, params: { section_id: section, message_ids: [message.id] }

      expect(user.read?(message)).to be_truthy
    end
  end
end
