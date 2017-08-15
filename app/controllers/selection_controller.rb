class SelectionController < ApplicationController
  def index
    @day = Day.find(params[:day_id])
    @teams_with_matches = Team.team_with_match_on(@day, current_section)

    @day_selections = Selection.joins(match: :day).where(matches: {day_id: @day.id}).includes(:user, :team)
    @users_already_selected = @day_selections.map(&:user).uniq
    @available_players = @day.matches.map { |match| match.availables-@users_already_selected }.flatten.compact.uniq
    @available_players.sort!{ |a, b| a.short_name <=> b.short_name }
  end

  def create
  end
end
