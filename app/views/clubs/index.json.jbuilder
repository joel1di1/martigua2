# frozen_string_literal: true

json.array!(@clubs) do |club|
  json.extract! club, :id, :name
  json.url club_url(club, format: :json)
end
