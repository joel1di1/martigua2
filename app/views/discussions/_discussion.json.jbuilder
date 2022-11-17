# frozen_string_literal: true

json.extract! discussion, :id, :section_id, :name, :private, :system, :created_at, :updated_at
json.url discussion_url(discussion, format: :json)
