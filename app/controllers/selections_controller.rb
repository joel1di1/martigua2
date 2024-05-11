# frozen_string_literal: true

class SelectionsController < ApplicationController
  def index
    @day = Day.find(params[:day_id])
    @teams_with_matches = Team.team_with_match_on(@day, current_section)

    @day_selections = Selection.joins(match: :day).where(matches: { day_id: @day.id }).includes(:user)
    @users_already_selected = @day_selections.map(&:user).uniq

    matches = @teams_with_matches.map(&:second)
    @players = current_section.players

    @availabilities_by_user_and_match = availabilities_by_user_and_match(@players, matches)

    @available_players, @non_available_players = prepare_availabilities(matches, @availabilities_by_user_and_match)

    @available_players = (@available_players - @users_already_selected).to_a.sort_by(&:short_name)
    @non_available_players = (@non_available_players - @available_players - @users_already_selected).to_a.sort_by(&:short_name)
    @no_response_players = (@players - @available_players - @non_available_players - @users_already_selected).to_a.sort_by(&:short_name)

    @last_trainings, @presences_by_user_and_training = prepare_training_presences(current_section, @players)
  end

  def prepare_availabilities(matches, availabilities_by_user_and_match)
    available_players = Set.new
    non_available_players = Set.new

    availabilities = MatchAvailability.includes(:user).where(match: matches)
    availabilities.each do |availability|
      if availabilities_by_user_and_match[availability.user_id]
        availabilities_by_user_and_match[availability.user_id][availability.match_id] =
          availability.available
      end
      (availability.available ? available_players : non_available_players) << availability.user
    end

    [available_players, non_available_players]
  end

  def availabilities_by_user_and_match(players, matches)
    availabilities_by_user_and_match = {}
    players.each do |player|
      availabilities_by_user_and_match[player.id] = {}
      matches.each { |match| availabilities_by_user_and_match[player.id][match.id] = nil }
    end
    availabilities_by_user_and_match
  end

  def destroy
    selection = Selection.find(params[:id])
    selection.destroy!

    respond_to do |format|
      format.html { redirect_with(fallback: root_path) }
    end
  end
end
