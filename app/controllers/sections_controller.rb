class SectionsController < ApplicationController
  def show
    @section = Section.find(params[:id])
    redirect_to section_trainings_path(@section)
  end
end
