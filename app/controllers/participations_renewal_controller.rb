class ParticipationsRenewalController < ApplicationController
  def index
    @previous_season = Season.current.previous
    @previous_season_members = current_section.members(season: @previous_season)
  end

  def create
    renew_players
    renew_coachs
    redirect_to section_users_path(current_section)
  rescue ActiveRecord::RecordNotFound
    redirect_to section_participations_renewal_index_path(current_section), notice: "Erreur, un membre n'a pas été trouvé lors de son enregistrement, veuillez réessayer ou contacter JOE si ça continue à ne par marcher"
  end

  private

  def renew_players
    players = params[:players_ids] ? User.find(params[:players_ids]) : []
    players.each { |player| current_section.add_player!(player) }
  end

  def renew_coachs
    coachs = params[:coachs_ids] ? User.find(params[:coachs_ids]) : []
    coachs.each { |coach| current_section.add_coach!(coach) }
  end
end
