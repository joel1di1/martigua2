# frozen_string_literal: true

json.array!(@groups) do |group|
  json.extract! group, :id, :name, :description, :section_id, :color
  json.url group_url(group, format: :json)
end
