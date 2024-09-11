# frozen_string_literal: true

json.extract! absence, :id, :user_id, :start_at, :end_at, :name, :comment, :created_at, :updated_at
json.url absence_url(absence, format: :json)
