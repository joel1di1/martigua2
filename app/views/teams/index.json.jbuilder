# frozen_string_literal: true

json.array!(@teams) do |team|
  json.extract! team, :id, :club_id, :name
  json.url team_url(team, format: :json)
end
