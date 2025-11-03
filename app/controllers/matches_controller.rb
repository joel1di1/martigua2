# frozen_string_literal: true

class MatchesController < ApplicationController
  def index
    @section = Section.find params[:section_id]
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
    @match = Match.find params[:id]
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

  def edit
    @championship = Championship.find(params[:championship_id])
    @match = Match.find params[:id]
  end

  def create
    @championship = Championship.find(params[:match][:championship_id])
    @match = Match.new match_params
    if @match.save
      redirect_to section_championship_path(current_section, @championship), notice: 'Match créé'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @championship = Championship.find(params[:championship_id])
    @match = Match.find params[:id]
    if @match.update match_params
      redirect_to section_championship_path(current_section, @championship)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def selection
    @user = User.find(params[:user_id])
    team = Team.find(params[:team_id])
    @match = Match.find(params[:id])

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
    @match = Match.find params[:id]
    @match.destroy!
    redirect_with(fallback: root_path)
  end

  def invitations
    @match = Match.find params[:id]

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

  private

  def preload_current_user_availabilities
    match_ids = @next_matches.map(&:id)
    @current_user_availabilities = MatchAvailability.where(
      user: current_user,
      match_id: match_ids
    ).index_by(&:match_id)
  end

  def precompute_match_availability_counts
    match_ids = @next_matches.map(&:id)
    section_player_ids = @section.players.pluck(:id)

    availability_counts = MatchAvailability
                          .where(match_id: match_ids, user_id: section_player_ids)
                          .group(:match_id, :available)
                          .count

    absences_by_match = calculate_absences_by_match(section_player_ids)

    @match_availability_counts = build_availability_counts_hash(
      availability_counts,
      absences_by_match,
      section_player_ids.size
    )
  end

  def calculate_absences_by_match(section_player_ids)
    absences_by_match = Hash.new(0)
    return absences_by_match if section_player_ids.empty?

    min_match_time = @next_matches.map { |m| m.start_datetime || m.day&.period_start_date }.compact.min
    max_match_time = @next_matches.map { |m| m.start_datetime || m.day&.period_end_date }.compact.max
    return absences_by_match unless min_match_time && max_match_time

    absences = fetch_absences_for_period(min_match_time, max_match_time)
    match_absences_to_matches(absences, absences_by_match)

    absences_by_match
  end

  def fetch_absences_for_period(min_match_time, max_match_time)
    Participation
      .joins(user: :absences)
      .where(section: @section, season: Season.current, role: Participation::PLAYER)
      .where('absences.start_at < ? AND absences.end_at > ?', max_match_time, min_match_time)
      .select('DISTINCT participations.user_id, absences.start_at, absences.end_at')
  end

  def match_absences_to_matches(absences, absences_by_match)
    @next_matches.each do |match|
      start_time = match.start_datetime || match.day&.period_start_date
      end_time = match.start_datetime || match.day&.period_end_date
      next if start_time.blank? || end_time.blank?

      absences_by_match[match.id] = absences.count do |absence|
        absence.start_at < start_time && absence.end_at > end_time
      end
    end
  end

  def build_availability_counts_hash(availability_counts, absences_by_match, total_players)
    counts_hash = {}
    @next_matches.each do |match|
      available_count = availability_counts[[match.id, true]] || 0
      not_available_count = availability_counts[[match.id, false]] || 0
      away_count = absences_by_match[match.id] || 0

      actual_available = [available_count - away_count, 0].max
      actual_not_available = not_available_count + away_count
      no_response_count = total_players - available_count - not_available_count

      counts_hash[match.id] = {
        available: actual_available,
        not_available: actual_not_available,
        no_response: no_response_count
      }
    end
    counts_hash
  end
end
