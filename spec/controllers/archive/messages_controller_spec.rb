# frozen_string_literal: true

require 'rails_helper'

describe MessagesController do
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

      post :mark_as_read, params: { section_id: section, message_ids: [message.id] }

      expect(user).to be_read(message)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:message_attributes) { attributes_for(:message) }

      it 'creates a new message' do
        expect do
          post :create, params: { section_id: section.id, channel_id: channel.id, message: message_attributes }
        end.to change(Message, :count).by(1)
        expect(Message.last.content.body.to_s).to include(message_attributes[:content])
        expect(Message.last.channel).to eq(channel)
        expect(Message.last.user).to eq(user)
      end

      it 'assigns the current user as the message user' do
        post :create, params: { section_id: section.id, channel_id: channel.id, message: message_attributes }
        expect(assigns(:message).user).to eq(user)
      end

      it 'redirects to the channel page' do
        post :create, params: { section_id: section.id, channel_id: channel.id, message: message_attributes }
        expect(response).to redirect_to(section_channel_path(section, channel))
      end
    end

    context 'with invalid attributes' do
      let(:invalid_message_attributes) { attributes_for(:message, content: nil) }

      it 'does not create a new message' do
        expect do
          post :create, params: { section_id: section.id, channel_id: channel.id, message: invalid_message_attributes }
        end.not_to change(Message, :count)
      end

      it 'renders the new template' do
        post :create, params: { section_id: section.id, channel_id: channel.id, message: invalid_message_attributes }
        expect(response).to redirect_to(section_channel_path(section, channel))
      end
    end
  end
end
