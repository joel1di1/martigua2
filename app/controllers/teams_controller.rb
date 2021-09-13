# frozen_string_literal: true

class TeamsController < InheritedResources::Base
  def create
    @team = Team.new team_params
    @team.club_id ||= Club.find_or_create_by(name: 'Les Connards').id
    @team.save!

    if params[:championship_id].present?
      championship = Championship.find(params[:championship_id])
      championship.enroll_team! @team
    end

    redirect_with additionnal_params: { adversary_team_id: @team.id }, notice: 'Equipe créée'
  end

  def new
    @team = Team.new(club: current_section&.club)
  end

  private

  def team_params
    params.require(:team).permit(:name, :club_id, section_ids: [])
  end
end
