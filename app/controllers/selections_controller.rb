# frozen_string_literal: true

class SelectionsController < ApplicationController
  def index
    @day = Day.find(params[:day_id])
    @teams_with_matches = Team.team_with_match_on(@day, current_section)

    @players = current_section.players.includes(:user_championship_stats, :absences)
    players_by_id = @players.index_by(&:id)

    @day_selections = Selection.joins(match: :day).where(matches: { day_id: @day.id })
    @users_already_selected = @day_selections.map(&:user_id).uniq.map { |id| players_by_id[id] }

    matches = @teams_with_matches.map(&:second)

    @availabilities_by_user_and_match = availabilities_by_user_and_match(@players, matches)
    @available_players, @non_available_players = prepare_availabilities(matches, @availabilities_by_user_and_match, players_by_id)

    # absence overrides availability
    @players.each do |player|
      matches.each do |match|
        next unless player.absent_for?(match)

        @availabilities_by_user_and_match[player.id][match.id] = false
        @available_players.delete(player)
        @non_available_players << player
      end
    end

    @available_players = (@available_players - @users_already_selected).to_a.sort_by(&:short_name)
    @non_available_players = (@non_available_players - @available_players - @users_already_selected).to_a.sort_by(&:short_name)
    @no_response_players = (@players - @available_players - @non_available_players - @users_already_selected).to_a.sort_by(&:short_name)

    @last_trainings, @presences_by_user_and_training = prepare_training_presences(current_section, @players)
  end

  def prepare_availabilities(matches, availabilities_by_user_and_match, players_by_id)
    available_players = Set.new
    non_available_players = Set.new

    availabilities = MatchAvailability.where(match: matches)
    availabilities.each do |availability|
      if availabilities_by_user_and_match[availability.user_id]
        availabilities_by_user_and_match[availability.user_id][availability.match_id] =
          availability.available
      end
      (availability.available ? available_players : non_available_players) << players_by_id[availability.user_id]
    end

    # remove nil values
    non_available_players.delete(nil)
    available_players.delete(nil)

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
