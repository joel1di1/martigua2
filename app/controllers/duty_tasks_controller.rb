# frozen_string_literal: true

class DutyTasksController < ApplicationController
  def index
    @duty_tasks = DutyTask.for_current_season.order(realised_at: :desc).page(params[:page])
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
