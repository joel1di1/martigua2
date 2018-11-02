class SectionsController < ApplicationController
  def show
    @section = Section.find(params[:id])
    @next_trainings = @section.next_trainings
    @next_matches = @section.next_matches
  end

  def new
    @section = Section.new(params[:section] ? section_params : nil)
    
    club = Club.find(params[:club_id])
    @section.club = club
  end

  def create
    @section = Section.new section_params
    club = Club.find(params[:club_id])
    @section.club = club

    if @section.save
      @section.add_coach!(current_user)
      respond_to do |format|
        format.json { render json: @section, status: 201 }
        format.html { redirect_to section_users_path(section_id: @section.to_param) }
      end  
    else
      respond_to do |format|
        format.json { render json: @section, status: 400 }
        format.html { redirect_to new_club_section_path(club_id: club.to_param, section: section.attributes) }
      end  
    end
  end

  private 

    def section_params
      params.require(:section).permit(:name)
    end
end
