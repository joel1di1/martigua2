# frozen_string_literal: true

json.array! @duty_tasks, partial: 'duty_tasks/duty_task', as: :duty_task
