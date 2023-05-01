# frozen_string_literal: true

class ChannelsController < ApplicationController
  layout 'full_width'

  before_action :set_channel, only: %i[show edit update destroy]

  # GET /channels or /channels.json
  def index
    # find channel général
    @general_channel = current_section.general_channel

    # redirect to section channel
    redirect_to section_channel_path(current_section, @general_channel)
  end

  # GET /channels/1 or /channels/1.json
  def show
    @message = Message.new(channel: @general_channel)
  end

  # GET /channels/new
  def new
    @channel = current_section.channels.new
  end

  # GET /channels/1/edit
  def edit; end

  # POST /channels or /channels.json
  def create
    @channel = current_section.channels.new(channel_params)

    respond_to do |format|
      if @channel.save
        format.html { redirect_to channel_url(@channel), notice: 'Channel was successfully created.' }
        format.json { render :show, status: :created, location: @channel }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /channels/1 or /channels/1.json
  def update
    respond_to do |format|
      if @channel.update(channel_params)
        format.html { redirect_to channel_url(@channel), notice: 'Channel was successfully updated.' }
        format.json { render :show, status: :ok, location: @channel }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /channels/1 or /channels/1.json
  def destroy
    @channel.destroy

    respond_to do |format|
      format.html { redirect_to channels_url, notice: 'Channel was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_channel
    @channel = current_section.channels.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def channel_params
    params.require(:channel).permit(:name, :private)
  end
end
