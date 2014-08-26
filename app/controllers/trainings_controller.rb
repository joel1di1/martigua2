class TrainingsController < ApplicationController

  before_filter :set_current_training, only: [:invitations, :show]

  def index
    @trainings = Training.of_section(current_section)
  end

  def create
    training = Training.new training_params
    training.sections << current_section
    training.save!
    redirect_to section_trainings_path(section_id: current_section.to_param), notice: "Entrainement créé"
  end

  def new
    @training = Training.new
  end

  def invitations
    @training.send_invitations!
    redirect_to section_trainings_path(section_id: current_section.to_param), notice: "Notifications envoyées"
  end

  def show
  end

  private 
    def training_params
      params.require(:training).permit(:start_datetime, :end_datetime, :location_id)
    end

    def set_current_training
      @training = Training.of_section(current_section).where(id: params[:id]).take
    end

end
