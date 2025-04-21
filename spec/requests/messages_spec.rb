# frozen_string_literal: true

require 'rails_helper'

describe 'Messages' do
  let(:section) { create(:section) }
  let(:user) { create(:user, with_section: section) }
  let(:channel) { create(:channel, section:) }

  before do
    sign_in user, scope: :user
  end

  describe 'POST mark_as_read' do
    let!(:message) { create(:message, channel: section.general_channel) }

    it 'mark message as read' do
      expect(user).not_to be_read(message)

      post mark_as_read_messages_path(section), params: { message_ids: [message.id] }

      expect(user).to be_read(message)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:message_attributes) { attributes_for(:message) }

      it 'creates a new message' do
        expect do
          post section_channel_messages_path(section, channel), params: { message: message_attributes }
        end.to change(Message, :count).by(1)
        expect(Message.last.content.body.to_s).to include(message_attributes[:content])
        expect(Message.last.channel).to eq(channel)
        expect(Message.last.user).to eq(user)
      end

      it 'redirects to the channel page' do
        post section_channel_messages_path(section, channel), params: { message: message_attributes }
        expect(response).to redirect_to(section_channel_path(section, channel))
      end
    end

    context 'with invalid attributes' do
      let(:invalid_message_attributes) { attributes_for(:message, content: nil) }

      it 'does not create a new message' do
        expect do
          post section_channel_messages_path(section, channel), params: { message: invalid_message_attributes }
        end.not_to change(Message, :count)
      end

      it 'renders the new template' do
        post section_channel_messages_path(section, channel), params: { message: invalid_message_attributes }
        expect(response).to redirect_to(section_channel_path(section, channel))
      end
    end
  end
end
