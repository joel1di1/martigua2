# frozen_string_literal: true

class SectionsController < ApplicationController
  before_action :set_section, only: %i[show destroy]

  def show
    @next_trainings = @section.next_trainings.includes(:groups, :location)
    @next_matches = @section.next_matches.includes(:local_team, :visitor_team, :day, :location)
    @teams = @section.teams
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
        format.json { render json: @section, status: :created }
        format.html { redirect_to(section_users_path(section_id: @section.to_param), notice: "Section #{@section.name} créée") }
      end
    else
      respond_to do |format|
        format.json { render json: @section, status: :bad_request }
        format.html { redirect_to new_club_section_path(club_id: club.to_param, section: section.attributes) }
      end
    end
  end

  def destroy
    raise 'forbidden' unless current_user.admin_of?(@section.club)

    @section.destroy!
    redirect_with(fallback: club_path(@section.club),
                  notice: "Section #{@section.name} supprimée")
  end

  private

  def section_params
    params.require(:section).permit(:name)
  end

  def set_section
    @section = Section.find(params[:id])
  end
end
