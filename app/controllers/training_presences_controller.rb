# frozen_string_literal: true

class TrainingPresencesController < ApplicationController
  def show
    @player = User.find params[:user_id]
    @training = Training.find params[:training_id]
    @color = :green if @player.present_for?(@training)
    @color ||= :red if @player.set_present_for?(@training)
    @color ||= :yellow
  end

  def create
    current_user.present_for! Training.find(params[:training_id])
    redirect_with(fallback: root_path)
  end

  def destroy
    current_user.not_present_for! Training.find(params[:training_id])
    redirect_with(fallback: root_path)
  end

  def confirm_presence
    user = User.find params[:user_id]
    training = Training.find params[:training_id]

    user._confirm_presence!(training, params[:present].present?)

    respond_to do |format|
      format.turbo_stream do
        redirect_to section_training_user_training_presence_path(current_section, training, user)
      end
    end
  end
end
