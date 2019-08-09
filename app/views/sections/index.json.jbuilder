# frozen_string_literal: true

json.array!(@sections) do |section|
  json.extract! section, :id, :club_id, :name
  json.url section_url(section, format: :json)
end
