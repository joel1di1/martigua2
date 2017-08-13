class ParticipationsRenewalController < ApplicationController
  def index
    @previous_season = Season.current.previous
    @previous_season_members = current_section.members(@previous_season)
  end

  def create
    players = params[:players_ids] ? User.find(params[:players_ids]) : []
    coachs = params[:coachs_ids] ? User.find(params[:coachs_ids]) : []

    players.each { |player| current_section.add_player!(player) }
    coachs.each { |coach| current_section.add_coach!(coach) }

    redirect_to section_users_path(current_section)

  rescue ActiveRecord::RecordNotFound => e
    redirect_to section_participations_renewal_index_path(current_section), notice: "Erreur, un membre n'a pas été trouvé lors de son enregistrement, veuillez réessayer ou contacter JOE si ça continue à ne par marcher"
  end
end
