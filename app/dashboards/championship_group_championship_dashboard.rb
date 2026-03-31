# frozen_string_literal: true

require 'administrate/base_dashboard'

class ChampionshipGroupChampionshipDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    championship_group: Field::BelongsTo,
    championship: Field::BelongsTo,
    id: Field::Number,
    index: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    championship_group
    championship
    index
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    championship_group
    championship
    index
    id
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    championship_group
    championship
    index
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(cgc)
    "#{cgc.championship&.name} (index: #{cgc.index})"
  end
end
