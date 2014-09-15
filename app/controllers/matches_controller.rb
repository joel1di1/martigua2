class MatchesController < ApplicationController
  def new
    @championship = Championship.find(params[:championship_id])
    @match = Match.new params[:match]
  end
end
