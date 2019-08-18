# frozen_string_literal: true

class SelectionsController < ApplicationController
  def index
    @day = Day.find(params[:day_id])
    @teams_with_matches = Team.team_with_match_on(@day, current_section)

    @day_selections = Selection.joins(match: :day).where(matches: { day_id: @day.id }).includes(:user)
    @users_already_selected = @day_selections.map(&:user).uniq

    @available_players = Set.new
    @non_available_players = Set.new

    matches = @teams_with_matches.map(&:second)
    @players = current_section.players

    @availabilities_by_user_and_match = {}
    @players.each do |player|
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

    @no_response_players = (@players - @available_players - @non_available_players - @users_already_selected).to_a
    @no_response_players.sort! { |a, b| a.short_name <=> b.short_name }

    @last_trainings ||= Training.of_section(current_section).with_start_between(2.months.ago, 6.hours.from_now).last(10)
    presences = TrainingPresence.where(user: @players).where(training: @last_trainings)
    @presences_by_user_and_training = presences.map{|pres| [[pres.user_id, pres.training_id], pres]}.to_h
  end

  def destroy
    selection = Selection.find(params[:id])
    @match = selection.match
    @user = selection.user
    selection.destroy!

    respond_to do |format|
      format.js do
        @teams_with_matches = Team.team_with_match_on(@match.day, current_section)
        @availabilities_by_user_and_match = {}
        player = @user
        @availabilities_by_user_and_match[player.id] = {}

        matches = @match.day.matches
        matches.each { |match| @availabilities_by_user_and_match[player.id][match.id] = nil }

        @players_target = 'no-response-players'
        availabilities = MatchAvailability.includes(:user).where(match: matches, user: @user)
        availabilities.each do |availability|
          @availabilities_by_user_and_match[availability.user_id][availability.match_id] = availability.available if @availabilities_by_user_and_match[availability.user_id]
          if availability.available
            @players_target = 'available-players'
          elsif @players_target == 'no-response-players' && availability.available == false
            @players_target = '#non-available-players'
          end
        end

        @last_trainings ||= Training.of_section(current_section).with_start_between(2.months.ago, 6.hours.from_now).last(10)
        render 'matches/selection'
      end
      format.html { redirect_with(fallback: root_path) }
    end
  end
end
