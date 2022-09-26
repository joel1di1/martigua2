# frozen_string_literal: true

class MatchesController < ApplicationController
  def new
    @section_team = Team.find_by(id: params[:section_team_id])
    @match = Match.new match_params
    @championship = @match.championship || Championship.new

    @championship.enroll_team! Team.find_by(id: params[:adversary_team_id]) if params[:adversary_team_id].present? && @championship.persisted?
  end

  def create
    @championship = Championship.find(params[:match][:championship_id])
    @match = Match.new match_params
    if @match.save
      redirect_to section_championship_path(current_section, @championship)
    else
      render :new
    end
  end

  def show
    @match = Match.find params[:id]
    day = @match.day
    return if day.blank?

    @day_selections = Selection.joins(match: :day).where(matches: { day_id: day.id }).includes(:user, :team)
    @users_already_selected = @day_selections.map(&:user).uniq
    @team_by_user = {}
    @day_selections.each { |selection| @team_by_user[selection.user] = selection.team }
  end

  def edit
    @championship = Championship.find(params[:championship_id])
    @match = Match.find params[:id]
  end

  def update
    @championship = Championship.find(params[:championship_id])
    @match = Match.find params[:id]
    if @match.update match_params
      redirect_to section_championship_path(current_section, @championship)
    else
      render :edit
    end
  end

  def selection
    @user = User.find(params[:user_id])
    team = Team.find(params[:team_id])
    @match = Match.find(params[:id])

    @selection = Selection.create! user: @user, team: team, match: @match

    respond_to do |format|
      format.js do
        @players_target = "selection-match-#{@match.id}"
        @teams_with_matches = Team.team_with_match_on(@match.day, current_section)
        @availabilities_by_user_and_match = {}
        player = @user
        @availabilities_by_user_and_match[player.id] = {}

        matches = @match.day.matches
        matches.each { |match| @availabilities_by_user_and_match[player.id][match.id] = nil }

        availabilities = MatchAvailability.includes(:user).where(match: matches, user: @user)
        availabilities.each do |availability|
          if @availabilities_by_user_and_match[availability.user_id]
            @availabilities_by_user_and_match[availability.user_id][availability.match_id] =
              availability.available
          end
        end
        @last_trainings ||= Training.of_section(current_section).with_start_between(2.months.ago,
                                                                                    6.hours.from_now).last(10)
      end
      format.html { redirect_with(fallback: section_match_path(current_section, @match)) }
      format.json { render json: {}, status: :created }
    end
  end

  def destroy
    @match = Match.find params[:id]
    @match.destroy!
    redirect_with(fallback: root_path)
  end

  protected

  def match_params
    if params[:match].present?
      params.require(:match).permit(:visitor_team_id, :local_team_id, :start_datetime, :end_datetime,
                                    :meeting_datetime, :meeting_location, :location_id, :local_score, :visitor_score,
                                    :day_id, :championship_id)
    else
      {}
    end
  end
end
