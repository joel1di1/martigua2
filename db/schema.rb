# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140916002059) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "championships", force: true do |t|
    t.integer  "season_id",  null: false
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "championships", ["season_id"], name: "index_championships_on_season_id", using: :btree

  create_table "club_admin_roles", force: true do |t|
    t.integer  "club_id",    null: false
    t.integer  "user_id",    null: false
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "club_admin_roles", ["club_id"], name: "index_club_admin_roles_on_club_id", using: :btree
  add_index "club_admin_roles", ["user_id"], name: "index_club_admin_roles_on_user_id", using: :btree

  create_table "clubs", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "enrolled_team_championships", force: true do |t|
    t.integer  "team_id"
    t.integer  "championship_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "enrolled_team_championships", ["championship_id"], name: "index_enrolled_team_championships_on_championship_id", using: :btree
  add_index "enrolled_team_championships", ["team_id"], name: "index_enrolled_team_championships_on_team_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "name",                        null: false
    t.integer  "section_id"
    t.string   "description"
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "system",      default: false, null: false
    t.string   "role"
  end

  add_index "groups", ["section_id"], name: "index_groups_on_section_id", using: :btree

  create_table "groups_trainings", id: false, force: true do |t|
    t.integer "training_id", null: false
    t.integer "group_id",    null: false
  end

  add_index "groups_trainings", ["group_id"], name: "index_groups_trainings_on_group_id", using: :btree
  add_index "groups_trainings", ["training_id"], name: "index_groups_trainings_on_training_id", using: :btree

  create_table "groups_users", id: false, force: true do |t|
    t.integer "user_id",  null: false
    t.integer "group_id", null: false
  end

  add_index "groups_users", ["group_id"], name: "index_groups_users_on_group_id", using: :btree
  add_index "groups_users", ["user_id"], name: "index_groups_users_on_user_id", using: :btree

  create_table "locations", force: true do |t|
    t.string   "name",       null: false
    t.text     "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "match_availabilities", force: true do |t|
    t.integer  "match_id",                   null: false
    t.integer  "user_id",                    null: false
    t.boolean  "available",  default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "match_availabilities", ["match_id"], name: "index_match_availabilities_on_match_id", using: :btree
  add_index "match_availabilities", ["user_id"], name: "index_match_availabilities_on_user_id", using: :btree

  create_table "match_selections", force: true do |t|
    t.integer  "match_id",   null: false
    t.integer  "team_id",    null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "match_selections", ["match_id"], name: "index_match_selections_on_match_id", using: :btree
  add_index "match_selections", ["team_id"], name: "index_match_selections_on_team_id", using: :btree
  add_index "match_selections", ["user_id"], name: "index_match_selections_on_user_id", using: :btree

  create_table "matches", force: true do |t|
    t.integer  "championship_id"
    t.integer  "local_team_id"
    t.integer  "visitor_team_id"
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.date     "prevision_period_start"
    t.date     "prevision_period_end"
    t.integer  "local_score"
    t.integer  "visitor_score"
    t.integer  "location_id"
    t.datetime "meeting_datetime"
    t.string   "meeting_location"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "matches", ["championship_id"], name: "index_matches_on_championship_id", using: :btree
  add_index "matches", ["location_id"], name: "index_matches_on_location_id", using: :btree

  create_table "participations", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "section_id", null: false
    t.integer  "season_id",  null: false
    t.string   "role",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "participations", ["season_id"], name: "index_participations_on_season_id", using: :btree
  add_index "participations", ["section_id"], name: "index_participations_on_section_id", using: :btree
  add_index "participations", ["user_id"], name: "index_participations_on_user_id", using: :btree

  create_table "seasons", force: true do |t|
    t.string   "name",       null: false
    t.date     "start_date", null: false
    t.date     "end_date",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "section_user_invitations", force: true do |t|
    t.integer  "section_id",   null: false
    t.string   "email",        null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "nickname"
    t.string   "phone_number"
    t.string   "roles"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "section_user_invitations", ["section_id"], name: "index_section_user_invitations_on_section_id", using: :btree

  create_table "sections", force: true do |t|
    t.integer  "club_id",    null: false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sections", ["club_id"], name: "index_sections_on_club_id", using: :btree

  create_table "sections_trainings", id: false, force: true do |t|
    t.integer "training_id", null: false
    t.integer "section_id",  null: false
  end

  create_table "team_sections", force: true do |t|
    t.integer  "team_id",    null: false
    t.integer  "section_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "team_sections", ["section_id"], name: "index_team_sections_on_section_id", using: :btree
  add_index "team_sections", ["team_id"], name: "index_team_sections_on_team_id", using: :btree

  create_table "teams", force: true do |t|
    t.integer  "club_id",    null: false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teams", ["club_id"], name: "index_teams_on_club_id", using: :btree

  create_table "training_invitations", force: true do |t|
    t.integer  "training_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "training_invitations", ["training_id"], name: "index_training_invitations_on_training_id", using: :btree

  create_table "training_presences", force: true do |t|
    t.integer  "user_id",     null: false
    t.integer  "training_id", null: false
    t.boolean  "present"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "training_presences", ["training_id"], name: "index_training_presences_on_training_id", using: :btree
  add_index "training_presences", ["user_id"], name: "index_training_presences_on_user_id", using: :btree

  create_table "trainings", force: true do |t|
    t.datetime "start_datetime",     null: false
    t.datetime "end_datetime"
    t.integer  "location_id"
    t.boolean  "canceled"
    t.text     "cancelation_reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trainings", ["location_id"], name: "index_trainings_on_location_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "nickname"
    t.string   "phone_number"
    t.string   "authentication_token"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
