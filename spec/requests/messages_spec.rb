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

    context 'when the channel belongs to another section' do
      let(:other_channel) { create(:channel, section: create(:section)) }

      it 'returns not_found and does not create a message' do
        expect do
          post section_channel_messages_path(section, other_channel), params: { message: attributes_for(:message) }
        end.not_to change(Message, :count)
        expect(response).to have_http_status(:not_found)
      end
    end

    # Regression net for ActionController::ParamsWrapper (see
    # spec/requests/webpush_subscriptions_spec.rb): a JSON request body must still
    # reach message_params. The controller has no `format.json`, so the request
    # sends a JSON body with the default Accept header, like a browser fetch would.
    context 'with a JSON request body' do
      let(:json_headers) { { 'CONTENT_TYPE' => 'application/json' } }

      it 'creates a message from a nested JSON body' do
        expect do
          post section_channel_messages_path(section, channel),
               params: { message: { content: 'from json' } }.to_json, headers: json_headers
        end.to change(Message, :count).by(1)

        expect(Message.last.content.body.to_s).to include('from json')
        expect(Message.last.channel).to eq(channel)
        expect(Message.last.user).to eq(user)
      end

      # Wrapping only picks up real model attributes, and `content` is an ActionText
      # rich text, so a flat body wraps to an empty hash and message_params raises.
      it 'rejects a flat JSON body' do
        expect do
          post section_channel_messages_path(section, channel),
               params: { content: 'flat json' }.to_json, headers: json_headers
        end.not_to change(Message, :count)

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:message) { create(:message, channel:, user:) }

    it 'destroys a message belonging to the current section channel' do
      expect do
        delete section_channel_message_path(section, channel, message)
      end.to change(Message, :count).by(-1)
    end

    context 'when the channel belongs to another section' do
      let(:other_channel) { create(:channel, section: create(:section)) }
      let!(:other_message) { create(:message, channel: other_channel) }

      it 'returns not_found and does not destroy the message' do
        expect do
          delete section_channel_message_path(section, other_channel, other_message)
        end.not_to change(Message, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
