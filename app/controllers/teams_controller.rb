class TeamsController < InheritedResources::Base
  def create
    @team = Team.new team_params
    @team.club = Club.find_or_create_by(name: 'Les Connards')
    @team.save!

    if params[:championship_id].present?
      championship = Championship.find(params[:championship_id])
      championship.enroll_team! @team
    end

    redirect_to_with additionnal_params: {adversary_team_id: @team.id}, notice: 'Equipe créée'
  end

  private
    def team_params
      params.require(:team).permit(:name, :club)
    end
end
