# frozen_string_literal: true

class DutyTasksController < InheritedResources::Base
  def create
    @duty_task = DutyTask.new(duty_task_params)
    if @duty_task.save
      redirect_to section_duty_tasks_path(current_section), notice: 'TIG créée'
    else
      render :new
    end
  end


  private

  def duty_task_params
    params.require(:duty_task).permit(:key, :user_id, :realised_at)
  end
end
