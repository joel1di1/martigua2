class SelectionsController < ApplicationController

  def index
    @day = Day.find(params[:day_id])
    @teams_with_matches = Team.team_with_match_on(@day, current_section)

    @day_selections = Selection.joins(match: :day).where(matches: {day_id: @day.id}).includes(:user)
    @users_already_selected = @day_selections.map(&:user).uniq
    @available_players = @day.matches.includes(:local_team).map { |match| match.availables-@users_already_selected }.flatten.compact.uniq
    @available_players.sort!{ |a, b| a.short_name <=> b.short_name }

    @non_available_players = User.includes(:match_availabilities).joins(:match_availabilities).where(match_availabilities: {match: @day.matches, available: false})
    @non_available_players -= @available_players
    @non_available_players -= @users_already_selected

    @no_response_players = current_section.players.includes(:match_availabilities) - @available_players - @users_already_selected - @non_available_players
  end

  def destroy
    Selection.find(params[:id]).destroy
    redirect_to referer_url_or(root_path)
  end

end
