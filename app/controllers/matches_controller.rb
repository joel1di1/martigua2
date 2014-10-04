class MatchesController < ApplicationController
  def new
    @championship = Championship.find(params[:championship_id])
    @match = Match.new params[:match]
  end

  def create
    @championship = Championship.find(params[:championship_id])
    @match = Match.new match_params
    @match.championship = @championship
    if @match.save
      redirect_to section_championship_path(current_section, @championship)
    else
      render :new
    end
  end

  def show
    
    @match = Match.find params[:id]
  end

  def edit
    @championship = Championship.find(params[:championship_id])
    @match = Match.find params[:id]
  end

  def update
    @championship = Championship.find(params[:championship_id])
    @match = Match.find params[:id]
    if @match.update_attributes match_params
      redirect_to section_championship_path(current_section, @championship)
    else
      render :edit
    end
  end

  def selection
    user = User.find(params[:user_id])
    team = Team.find(params[:team_id])
    match = Match.find(params[:id])

    Selection.create! user: user, team: team, match: match

    respond_to do |format|
      format.json { render json: {}, status: :created }
      format.html { redirect_to referer_url_or(section_match_path(current_section, match)) }
    end

  end


  protected
    def match_params
      params.require(:match).permit(:visitor_team_id, :local_team_id, :start_datetime, :end_datetime, 
                                    :meeting_datetime, :meeting_location, :location_id, :local_score, :visitor_score,
                                    :prevision_period_start, :prevision_period_end)
    end
end



