# frozen_string_literal: true

class TrainingPresencesController < ApplicationController
  before_action :find_training
  before_action :find_player, only: %i[show confirm_presence]

  def show
    @color = :green if @player.present_for?(@training)
    @color ||= :red if @player.set_present_for?(@training)
    @show ||= :yellow
  end

  def create
    current_user.present_for! @training
    redirect_with(fallback: root_path)
  end

  def destroy
    current_user.not_present_for! @training
    redirect_with(fallback: root_path)
  end

  def confirm_presence
    @player._confirm_presence!(@training, params[:present].present?)

    respond_to do |format|
      format.turbo_stream do
        redirect_to section_training_user_training_presence_path(current_section, @training, @player)
      end
    end
  end

  private

  def find_training
    @training = Training.of_section(current_section).find(params.expect(:training_id))
  rescue ActiveRecord::RecordNotFound
    catch404
  end

  def find_player
    @player = current_section.users.find(params.expect(:user_id))
  rescue ActiveRecord::RecordNotFound
    catch404
  end
end
