class TrainingPresencesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:training_presences, :match_availabilities]

  def create
    current_user.present_for! Training.find(params[:training_id])
    redirect_to referer_url_or(root_path)
  end

  def destroy
    current_user.not_present_for! Training.find(params[:training_id])
    redirect_to referer_url_or(root_path)
  end
end
