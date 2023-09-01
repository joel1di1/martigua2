# frozen_string_literal: true

class DutyTasksController < ApplicationController
  def index
    task_scope = DutyTask.for_current_season.joins(user: :participations)
                         .where(users: { participations: { section: current_section, season: Season.current } })

    @duty_tasks = task_scope.order(realised_at: :desc).page(params[:page])

    all_tasks = task_scope.to_a
    @players_with_tasks = current_section.players.map do |player|
      player_tasks = all_tasks.select { |task| task.user_id == player.id }
      Rails.logger.debug { "#{player.short_name} : #{player_tasks.sum(&:weight)}" }
      [
        player,
        player_tasks,
        player_tasks.sum(&:weight)
      ]
    end
    @players_with_tasks = @players_with_tasks.sort_by { |_, _, weight| weight }.reverse
  end

  def new
    @duty_task = DutyTask.new
  end

  def create
    @duty_task = DutyTask.new(duty_task_params.merge(club: current_section.club))
    if @duty_task.save
      redirect_to section_duty_tasks_path(current_section), notice: 'TIG créée'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def duty_task_params
    params.require(:duty_task).permit(:key, :user_id, :realised_at)
  end
end
