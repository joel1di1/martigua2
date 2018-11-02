# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171204231461) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.string "author_type"
    t.integer "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "calendars", force: :cascade do |t|
    t.integer "season_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["season_id"], name: "index_calendars_on_season_id"
  end

  create_table "championships", force: :cascade do |t|
    t.integer "season_id", null: false
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "calendar_id"
    t.index ["calendar_id"], name: "index_championships_on_calendar_id"
    t.index ["season_id"], name: "index_championships_on_season_id"
  end

  create_table "club_admin_roles", force: :cascade do |t|
    t.integer "club_id", null: false
    t.integer "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["club_id"], name: "index_club_admin_roles_on_club_id"
    t.index ["user_id"], name: "index_club_admin_roles_on_user_id"
  end

  create_table "clubs", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "days", force: :cascade do |t|
    t.string "name", null: false
    t.date "period_start_date"
    t.date "period_end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "calendar_id"
    t.index ["calendar_id"], name: "index_days_on_calendar_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "enrolled_team_championships", force: :cascade do |t|
    t.integer "team_id"
    t.integer "championship_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["championship_id"], name: "index_enrolled_team_championships_on_championship_id"
    t.index ["team_id"], name: "index_enrolled_team_championships_on_team_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.integer "section_id"
    t.string "description"
    t.string "color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "system", default: false, null: false
    t.string "role"
    t.integer "season_id"
    t.index ["season_id"], name: "index_groups_on_season_id"
    t.index ["section_id"], name: "index_groups_on_section_id"
  end

  create_table "groups_trainings", id: false, force: :cascade do |t|
    t.integer "training_id", null: false
    t.integer "group_id", null: false
    t.index ["group_id"], name: "index_groups_trainings_on_group_id"
    t.index ["training_id"], name: "index_groups_trainings_on_training_id"
  end

  create_table "groups_users", id: false, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "group_id", null: false
    t.index ["group_id"], name: "index_groups_users_on_group_id"
    t.index ["user_id"], name: "index_groups_users_on_user_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.text "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "match_availabilities", force: :cascade do |t|
    t.integer "match_id", null: false
    t.integer "user_id", null: false
    t.boolean "available", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["match_id"], name: "index_match_availabilities_on_match_id"
    t.index ["user_id"], name: "index_match_availabilities_on_user_id"
  end

  create_table "match_selections", force: :cascade do |t|
    t.integer "match_id", null: false
    t.integer "team_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["match_id"], name: "index_match_selections_on_match_id"
    t.index ["team_id"], name: "index_match_selections_on_team_id"
    t.index ["user_id"], name: "index_match_selections_on_user_id"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "championship_id"
    t.integer "local_team_id"
    t.integer "visitor_team_id"
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.date "prevision_period_start"
    t.date "prevision_period_end"
    t.integer "local_score"
    t.integer "visitor_score"
    t.integer "location_id"
    t.datetime "meeting_datetime"
    t.string "meeting_location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "day_id"
    t.string "shared_calendar_id"
    t.string "shared_calendar_url"
    t.index ["championship_id"], name: "index_matches_on_championship_id"
    t.index ["day_id"], name: "index_matches_on_day_id"
    t.index ["location_id"], name: "index_matches_on_location_id"
  end

  create_table "participations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "section_id", null: false
    t.integer "season_id", null: false
    t.string "role", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["season_id"], name: "index_participations_on_season_id"
    t.index ["section_id"], name: "index_participations_on_section_id"
    t.index ["user_id"], name: "index_participations_on_user_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.string "name", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "section_user_invitations", force: :cascade do |t|
    t.integer "section_id", null: false
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "nickname"
    t.string "phone_number"
    t.string "roles"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["section_id"], name: "index_section_user_invitations_on_section_id"
  end

  create_table "sections", force: :cascade do |t|
    t.integer "club_id", null: false
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["club_id"], name: "index_sections_on_club_id"
  end

  create_table "sections_trainings", id: false, force: :cascade do |t|
    t.integer "training_id", null: false
    t.integer "section_id", null: false
  end

  create_table "selections", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "match_id", null: false
    t.integer "team_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["match_id"], name: "index_selections_on_match_id"
    t.index ["team_id"], name: "index_selections_on_team_id"
    t.index ["user_id"], name: "index_selections_on_user_id"
  end

  create_table "sms_notifications", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "section_id"
    t.index ["section_id"], name: "index_sms_notifications_on_section_id"
  end

  create_table "starburst_announcement_views", force: :cascade do |t|
    t.integer "user_id"
    t.integer "announcement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "announcement_id"], name: "starburst_announcement_view_index", unique: true
  end

  create_table "starburst_announcements", force: :cascade do |t|
    t.text "title"
    t.text "body"
    t.datetime "start_delivering_at"
    t.datetime "stop_delivering_at"
    t.text "limit_to_users"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "category"
  end

  create_table "team_sections", force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "section_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["section_id"], name: "index_team_sections_on_section_id"
    t.index ["team_id"], name: "index_team_sections_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.integer "club_id", null: false
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["club_id"], name: "index_teams_on_club_id"
  end

  create_table "training_invitations", force: :cascade do |t|
    t.integer "training_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["training_id"], name: "index_training_invitations_on_training_id"
  end

  create_table "training_presences", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "training_id", null: false
    t.boolean "present"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["training_id"], name: "index_training_presences_on_training_id"
    t.index ["user_id"], name: "index_training_presences_on_user_id"
  end

  create_table "trainings", force: :cascade do |t|
    t.datetime "start_datetime", null: false
    t.datetime "end_datetime"
    t.integer "location_id"
    t.boolean "cancelled"
    t.text "cancel_reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["location_id"], name: "index_trainings_on_location_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: ""
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "first_name"
    t.string "last_name"
    t.string "nickname"
    t.string "phone_number"
    t.string "authentication_token"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "calendars", "seasons"
  add_foreign_key "championships", "calendars"
  add_foreign_key "days", "calendars"
  add_foreign_key "groups", "seasons"
  add_foreign_key "sms_notifications", "sections"
end
