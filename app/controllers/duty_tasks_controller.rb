# frozen_string_literal: true

class DutyTasksController < InheritedResources::Base
  private

  def duty_task_params
    params.require(:duty_task).permit(:name, :user_id, :realised_at)
  end
end
