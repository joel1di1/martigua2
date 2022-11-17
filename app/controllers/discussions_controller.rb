# frozen_string_literal: true

class DiscussionsController < ApplicationController
  layout 'full_width'

  before_action :set_discussion, only: %i[show edit update destroy]

  # GET /discussions or /discussions.json
  def index
    @discussions = current_section.discussions.all
  end

  # GET /discussions/1 or /discussions/1.json
  def show; end

  # GET /discussions/new
  def new
    @discussion = current_section.discussions.new
  end

  # GET /discussions/1/edit
  def edit; end

  # POST /discussions or /discussions.json
  def create
    @discussion = current_section.discussions.new(discussion_params)

    respond_to do |format|
      if @discussion.save
        format.html { redirect_to discussion_url(@discussion), notice: 'Discussion was successfully created.' }
        format.json { render :show, status: :created, location: @discussion }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @discussion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /discussions/1 or /discussions/1.json
  def update
    respond_to do |format|
      if @discussion.update(discussion_params)
        format.html { redirect_to discussion_url(@discussion), notice: 'Discussion was successfully updated.' }
        format.json { render :show, status: :ok, location: @discussion }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @discussion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /discussions/1 or /discussions/1.json
  def destroy
    @discussion.destroy

    respond_to do |format|
      format.html { redirect_to discussions_url, notice: 'Discussion was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_discussion
    @discussion = current_section.discussions.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def discussion_params
    params.require(:discussion).permit(:name, :private)
  end
end
