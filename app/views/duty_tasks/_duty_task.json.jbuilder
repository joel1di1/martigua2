# frozen_string_literal: true

json.extract! duty_task, :id, :name, :user_id, :realised_at, :created_at, :updated_at
json.url duty_task_url(duty_task, format: :json)
