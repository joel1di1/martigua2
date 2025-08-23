# frozen_string_literal: true

class EnrolledTeamChampionshipsController < ApplicationController
  # before_action :find_championship_by_id, except: [:index, :new, :create]

  def index
    @championship = Championship.find(params[:championship_id])
    @not_enrolled_teams = Team.where.not(id: @championship.enrolled_teams.select(:id)).order(:name)
    @enrolled_team_championships = @championship.enrolled_team_championships.sort { |a, b| a.team.name <=> b.team.name }
  end

  def create
    @championship = Championship.find params[:championship_id]
    @team = Team.find params[:team_id]
    @championship.enroll_team!(@team)
    redirect_to action: :index
  end
end
