# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_channel, except: [:mark_as_read]

  def create
    @message = @channel.messages.new(message_params)
    @message.user = current_user

    respond_to do |format|
      if @message.save
        format.html { redirect_to section_channel_path(current_section, @channel) }
        format.turbo_stream
        format.js
      else
        format.html { redirect_to section_channel_path(current_section, @channel) }
        format.js { render json: { errors: @message.errors }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @message = @channel.messages.find(params[:id])
    @message.destroy

    respond_to do |format|
      format.html { redirect_to section_channel_path(current_section, @channel) }
      format.turbo_stream
      format.js
    end
  end

  def mark_as_read
    message_ids = params[:message_ids].presence || []
    message_ids = message_ids.map(&:to_i)

    current_user.read!(message_ids)

    render json: {}
  end

  private

  def set_channel
    @channel = Channel.find(params[:channel_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
