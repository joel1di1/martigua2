# frozen_string_literal: true

class TrainingsController < ApplicationController
  before_action :set_current_training
  include PrefetchTrainingData

  def index
    Season.current.start_date
    section_trainings = current_section.trainings.eager_load(:location, :groups).where('start_datetime > ?', Season.current.start_date)

    if params[:page].blank?
      training_before_beginning_of_week =
        section_trainings.where('start_datetime < ?', Time.zone.now.beginning_of_week)
      page = (training_before_beginning_of_week.count / 10) + 1
      redirect_to section_trainings_path(current_section, page:)
      return
    end

    @trainings = section_trainings.page(params[:page])
    add_training_prefetch_data(@trainings)
  end

  def show
    if current_user.coach_of?(current_section)
      redirect_to presence_validation_section_training_path(current_section,
                                                            @training)
    end
  end

  def new
    @training = Training.new
  end

  def invitations
    @training.send_invitations!
    redirect_to section_trainings_path(section_id: current_section.to_param), notice: 'Notifications envoyées'
  end

  def edit; end

  def create
    @training = Training.new training_params
    @training.sections << current_section
    @training.groups = current_section.groups.where(id: params[:training][:group_ids])
    @training.save!
    redirect_to section_trainings_path(section_id: current_section.to_param), notice: 'Entrainement créé'
  end

  def update
    @training.assign_attributes(training_params)
    @training.groups = current_section.groups.where(id: params[:training][:group_ids])
    if @training.save
      redirect_to section_training_path(section_id: current_section.to_param, id: @training.to_param),
                  notice: 'Entrainement modifié'
    else
      render :edit
    end
  end

  def destroy
    @training.destroy
    redirect_to section_trainings_path(section_id: current_section.to_param), notice: 'Entrainement supprimé'
  end

  def cancellation
    @training.cancel!(reason: params[:cancellation][:reason])
    redirect_with(fallback: section_training_path(current_section, @training))
  end

  def uncancel
    @training.uncancel!
    redirect_with(fallback: section_training_path(current_section, @training))
  end

  def presence_validation
    @players = current_section.players.sort_by(&:full_name)
  end

  private

  def training_params
    params.require(:training).permit(:start_datetime, :end_datetime, :location_id, :group_ids)
  end

  def set_current_training
    @training = Training.of_section(current_section).where(id: params[:id]).take if params[:id]
  end
end
