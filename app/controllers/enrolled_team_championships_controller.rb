class EnrolledTeamChampionshipsController < ApplicationController
  # before_action :find_championship_by_id, except: [:index, :new, :create]

  def index
    @championship = Championship.find(params[:championship_id])
    @not_enrolled_teams = Team.where.not(id: @championship.enrolled_teams.select(:id)).order('name')
    @enrolled_team_championships = @championship.enrolled_team_championships.sort {|a, b| a.team.name <=> b.team.name}
  end

  def create
    @championship = Championship.find params[:championship_id]
    @team = Team.find params[:team_id]
    @championship.enroll_team!(@team)
    redirect_to action: :index
  end

  def destroy
    enrolled_team_championship = EnrolledTeamChampionship.find params[:id]
    @championship = Championship.find params[:championship_id]
    team = enrolled_team_championship.team

    redirect_to action: :index
  end
end
