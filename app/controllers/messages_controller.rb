# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_channel

  def create
    @message = @channel.messages.new(message_params)
    @message.user = current_user
    @message.save!
  end

  private

  def set_channel
    @channel = Channel.find(params[:channel_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
