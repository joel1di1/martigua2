# frozen_string_literal: true

json.extract! channel, :id, :section_id, :name, :private, :system, :created_at, :updated_at
json.url channel_url(channel, format: :json)
