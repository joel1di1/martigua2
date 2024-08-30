# frozen_string_literal: true

json.extract! injury, :id, :user_id, :start_at, :end_at, :name, :comment, :created_at, :updated_at
json.url injury_url(injury, format: :json)
