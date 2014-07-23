class TrainingsController < ApplicationController
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

  private 
    def training_params
      params.require(:training).permit(:start_datetime, :end_datetime)
    end

end
