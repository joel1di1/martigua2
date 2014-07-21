class TrainingsController < ApplicationController
  def index
    @trainings = Training.of_section(current_section)
  end
end
