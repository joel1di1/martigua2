# frozen_string_literal: true

class TrainingPresencesController < ApplicationController
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
  end

  def confirm_presence_get
    current_user.present_for! Training.find(params[:training_id])
    redirect_with(fallback: root_path)
  end
end
