# frozen_string_literal: true

class PlayerStatsController < ApplicationController
  SORTABLE_COLUMNS = %w[
    first_name matches_played total_goals total_seven_meters total_shots
    total_saves total_warnings total_two_minutes total_disqualifications goal_percentage
  ].freeze

  def index
    @championships = Championship.where(id: current_section.championships.where(season: Season.current).select(:id)).order(:name)
    @championship = @championships.find_by(id: params[:championship_id])
    @matches = load_matches
    @position_filter = params[:position]

    scope = base_scope
    scope = scope.for_championship(@championship) if @championship
    scope = scope.where(match_id: params[:match_id]) if params[:match_id].present?
    scope = apply_date_filter(scope)

    @aggregated_stats = aggregate(scope)
    @participations_by_user = load_participations
    @aggregated_stats = filter_by_position(@aggregated_stats) if @position_filter.present?
    @section_players = current_section.players.order(:first_name, :last_name) if current_user.coach_of?(current_section)
  end

  def associate_player
    return head :forbidden unless current_user.coach_of?(current_section)

    user = current_section.players.find(params.expect(:user_id))
    associate_player_with_user!(user)

    redirect_back_or_to(section_player_stats_path(current_section), notice: "#{user.full_name} a été associé.")
  end

  private

  def associate_player_with_user!(user)
    PlayerMatchStat.where(player_id: params[:player_id]).update_all(user_id: user.id) # rubocop:disable Rails/SkipsModelValidations

    UserChampionshipStat
      .where(championship: current_section.championships)
      .where('UPPER(TRIM(last_name)) = ? AND UPPER(TRIM(first_name)) = ?',
             params[:last_name].to_s.strip.upcase, params[:first_name].to_s.strip.upcase)
      .update_all(user_id: user.id) # rubocop:disable Rails/SkipsModelValidations
  end

  def base_scope
    PlayerMatchStat.where(match_id: Match.where(championship_id: @championships.select(:id)).select(:id))
                   .for_teams(current_section.teams)
  end

  def apply_date_filter(scope)
    if params[:start_date].present? && params[:end_date].present?
      scope.in_date_range(Date.parse(params[:start_date]), Date.parse(params[:end_date]).end_of_day)
    else
      scope
    end
  end

  def aggregate(scope)
    results = scope.group(:player_id, :first_name, :last_name)
                   .select(
                     :player_id, :first_name, :last_name,
                     'MAX(user_id) as user_id',
                     'COUNT(DISTINCT match_id) as matches_played',
                     'SUM(goals) as total_goals',
                     'SUM(seven_meters) as total_seven_meters',
                     'SUM(shots) as total_shots',
                     'SUM(saves) as total_saves',
                     'SUM(warnings) as total_warnings',
                     'SUM(two_minutes) as total_two_minutes',
                     'SUM(disqualifications) as total_disqualifications'
                   )

    apply_sort(results)
  end

  def apply_sort(scope)
    col = SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : 'total_goals'
    dir = params[:direction] == 'asc' ? :asc : :desc

    if col == 'goal_percentage'
      scope.order(Arel.sql("CASE WHEN (SUM(shots) + SUM(seven_meters)) > 0 THEN SUM(goals)::float / (SUM(shots) + SUM(seven_meters)) ELSE 0 END #{dir == :asc ? 'ASC' : 'DESC'}"))
    elsif col == 'first_name'
      scope.order(first_name: dir, last_name: dir)
    else
      scope.order(col => dir)
    end
  end

  def filter_by_position(stats)
    user_ids = @participations_by_user.select { |_, p| p.main_position == @position_filter }.keys
    stats.select { |s| user_ids.include?(s.user_id) }
  end

  def load_matches
    if @championship
      @championship.matches.joins(:day).merge(Day.order(period_start_date: :desc))
    else
      Match.where(championship_id: @championships.select(:id)).joins(:day).merge(Day.order(period_start_date: :desc))
    end
  end

  def load_participations
    Participation.where(section: current_section, season: Season.current, role: Participation::PLAYER)
                 .index_by(&:user_id)
  end
end
