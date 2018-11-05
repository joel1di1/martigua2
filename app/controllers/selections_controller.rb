class SelectionsController < ApplicationController
  def index
    @day = Day.find(params[:day_id])
    @teams_with_matches = Team.team_with_match_on(@day, current_section)

    @day_selections = Selection.joins(match: :day).where(matches: { day_id: @day.id }).includes(:user)
    @users_already_selected = @day_selections.map(&:user).uniq
    @available_players = @day.matches.includes(:local_team).map { |match| match.availables - @users_already_selected }.flatten.compact.uniq
    @available_players.sort! { |a, b| a.short_name <=> b.short_name }

    @non_available_players = User.joins(:match_availabilities).where(match_availabilities: { match: @day.matches, available: false })
    @non_available_players -= @available_players
    @non_available_players -= @users_already_selected

    @no_response_players = current_section.players.includes(:match_availabilities) - @available_players - @users_already_selected - @non_available_players


    matches = @teams_with_matches.map(&:second)
    players = current_section.players

    @availabilities_by_user_and_match = {}
    players.each do |player|
      @availabilities_by_user_and_match[player.id] = {}
      matches.each { |match| @availabilities_by_user_and_match[player.id][match.id] = nil }
    end

    availabilities = MatchAvailability.where(match: matches)
    availabilities.each do |availability|
      @availabilities_by_user_and_match[availability.user_id][availability.match_id] = availability.available if @availabilities_by_user_and_match[availability.user_id]
    end

  end

  def destroy
    Selection.find(params[:id]).destroy!
    redirect_with(fallback: root_path)
  end
end
