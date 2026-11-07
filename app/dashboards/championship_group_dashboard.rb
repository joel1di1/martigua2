# frozen_string_literal: true

require 'administrate/base_dashboard'

class ChampionshipGroupDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    championship_group_championships: Field::HasMany,
    championships: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    name
    championships
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    championship_group_championships
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    name
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(championship_group)
    championship_group.name
  end
end
