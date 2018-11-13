class SelectionsController < ApplicationController
  def index
    @day = Day.find(params[:day_id])
    @teams_with_matches = Team.team_with_match_on(@day, current_section)

    @day_selections = Selection.joins(match: :day).where(matches: { day_id: @day.id }).includes(:user)
    @users_already_selected = @day_selections.map(&:user).uniq

    @available_players = Set.new
    @non_available_players = Set.new

    matches = @teams_with_matches.map(&:second)
    players = current_section.players

    @availabilities_by_user_and_match = {}
    players.each do |player|
      @availabilities_by_user_and_match[player.id] = {}
      matches.each { |match| @availabilities_by_user_and_match[player.id][match.id] = nil }
    end

    availabilities = MatchAvailability.includes(:user).where(match: matches)
    availabilities.each do |availability|
      @availabilities_by_user_and_match[availability.user_id][availability.match_id] = availability.available if @availabilities_by_user_and_match[availability.user_id]
      (availability.available ? @available_players : @non_available_players) << availability.user
    end

    @available_players = (@available_players - @users_already_selected).to_a
    @available_players.sort! { |a, b| a.short_name <=> b.short_name }

    @non_available_players = (@non_available_players - @available_players - @users_already_selected).to_a
    @non_available_players.sort! { |a, b| a.short_name <=> b.short_name }

    @no_response_players = (players - @available_players - @non_available_players - @users_already_selected).to_a
    @no_response_players.sort! { |a, b| a.short_name <=> b.short_name }
  end

  def destroy
    Selection.find(params[:id]).destroy!
    redirect_with(fallback: root_path)
  end
end
