require "administrate/base_dashboard"

class MatchDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    championship: Field::BelongsTo,
    location: Field::BelongsTo,
    day: Field::BelongsTo,
    local_team: Field::BelongsTo.with_options(class_name: "Team"),
    visitor_team: Field::BelongsTo.with_options(class_name: "Team"),
    selections: Field::HasMany,
    match_availabilities: Field::HasMany,
    id: Field::Number,
    local_team_id: Field::Number,
    visitor_team_id: Field::Number,
    start_datetime: Field::DateTime,
    end_datetime: Field::DateTime,
    prevision_period_start: Field::DateTime,
    prevision_period_end: Field::DateTime,
    local_score: Field::Number,
    visitor_score: Field::Number,
    meeting_datetime: Field::DateTime,
    meeting_location: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    shared_calendar_id: Field::String,
    shared_calendar_url: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  championship
  location
  day
  local_team
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  championship
  location
  day
  local_team
  visitor_team
  selections
  match_availabilities
  id
  local_team_id
  visitor_team_id
  start_datetime
  end_datetime
  prevision_period_start
  prevision_period_end
  local_score
  visitor_score
  meeting_datetime
  meeting_location
  created_at
  updated_at
  shared_calendar_id
  shared_calendar_url
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  championship
  location
  day
  local_team
  visitor_team
  selections
  match_availabilities
  local_team_id
  visitor_team_id
  start_datetime
  end_datetime
  prevision_period_start
  prevision_period_end
  local_score
  visitor_score
  meeting_datetime
  meeting_location
  shared_calendar_id
  shared_calendar_url
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how matches are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(match)
  #   "Match ##{match.id}"
  # end
end
