# frozen_string_literal: true

class MatchesController < ApplicationController
  include PrefetchMatchData

  before_action :find_championship_for_match, only: %i[edit create update]
  before_action :find_match_by_id, only: %i[show edit update destroy selection invitations]

  def index
    @section = Section.find params.expect(:section_id)
    @next_matches = @section.next_matches(end_date: 1.year.from_now).includes(
      :local_team,
      :visitor_team,
      :day,
      :location,
      :championship,
      match_availabilities: :user
    )

    @current_user_is_player = current_user.player_of?(@section)
    preload_current_user_availabilities
    precompute_match_availability_counts
  end

  def show
    day = @match.day
    return if day.blank?

    @day_selections = Selection.joins(match: :day).where(matches: { day_id: day.id }).includes(:user, :team)
    @users_already_selected = @day_selections.map(&:user).uniq
    @team_by_user = {}
    @day_selections.each { |selection| @team_by_user[selection.user] = selection.team }
  end

  def new
    @section_team = Team.find_by(id: params[:section_team_id])
    @match = Match.new match_params
    @championship = @match.championship || Championship.new

    return unless params[:adversary_team_id].present? && @championship.persisted?

    @championship.enroll_team! Team.find_by(id: params[:adversary_team_id])
  end

  def edit; end

  def create
    @match = @championship.matches.new(match_params.except(:championship_id))
    if @match.save
      redirect_to section_championship_path(current_section, @championship), notice: 'Match créé'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @match.update(match_params.except(:championship_id))
      redirect_to section_championship_path(current_section, @championship)
    else
      render :edit, status: :unprocessable_content
    end
  end

  def selection
    @user = User.find(params.expect(:user_id))
    team = Team.find(params.expect(:team_id))

    @selection = Selection.create! user: @user, team:, match: @match

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
    @match.destroy!
    redirect_with(fallback: root_path)
  end

  def invitations
    MatchInvitation.create!(match: @match, user: current_user)
    redirect_to section_path(current_section), notice: 'Relance envoyée !'
  end

  protected

  def match_params
    if params[:match].present?
      params.expect(match: %i[visitor_team_id local_team_id start_datetime end_datetime
                              meeting_datetime meeting_location location_id local_score visitor_score
                              day_id championship_id])
    else
      {}
    end
  end

  def find_championship_for_match
    championship_id = params[:championship_id] || params.expect(match: [:championship_id])[:championship_id]
    @championship = Championship.find(championship_id)
    verify_section_ownership!(:championships, id: @championship.id)
  rescue ActiveRecord::RecordNotFound
    catch404
  end

  def find_match_by_id
    @match = Match.find params.expect(:id)
    verify_section_ownership!(:championships, id: @match.championship_id)
  rescue ActiveRecord::RecordNotFound
    catch404
  end
end
