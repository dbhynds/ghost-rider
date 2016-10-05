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

ActiveRecord::Schema.define(version: 20160921190848) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_steps", force: :cascade do |t|
    t.integer  "ghost_step_id"
    t.string   "start_time"
    t.string   "heading"
    t.boolean  "arriving_at_origin", default: false
    t.boolean  "arrived_at_origin",  default: false
    t.boolean  "arriving_at_dest",   default: false
    t.boolean  "arrived_at_dest",    default: false
    t.string   "request"
    t.string   "arriving_vehicles"
    t.string   "watched_vehicles"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "active_steps", ["ghost_step_id"], name: "index_active_steps_on_ghost_step_id", using: :btree

  create_table "busdirections", force: :cascade do |t|
    t.string   "dir"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "commutes", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "origin"
    t.string   "dest"
    t.string   "departure_time"
    t.float    "origin_lat"
    t.float    "origin_long"
    t.float    "dest_lat"
    t.float    "dest_long"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "commutes", ["user_id"], name: "index_commutes_on_user_id", using: :btree

  create_table "ghost_commutes", force: :cascade do |t|
    t.integer  "commute_id"
    t.integer  "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ghost_commutes", ["commute_id"], name: "index_ghost_commutes_on_commute_id", using: :btree

  create_table "ghost_steps", force: :cascade do |t|
    t.integer  "ghost_commute_id"
    t.string   "mode"
    t.string   "step_type"
    t.string   "line"
    t.string   "origin"
    t.float    "origin_lat"
    t.float    "origin_long"
    t.string   "dest"
    t.float    "dest_lat"
    t.float    "dest_long"
    t.string   "heading"
    t.string   "duration"
    t.boolean  "completed",        default: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "ghost_steps", ["ghost_commute_id"], name: "index_ghost_steps_on_ghost_commute_id", using: :btree

  create_table "routes", force: :cascade do |t|
    t.string   "route_id"
    t.string   "route_short_name"
    t.string   "route_long_name"
    t.string   "route_type"
    t.string   "route_url"
    t.string   "route_color"
    t.string   "route_text_color"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "stops", force: :cascade do |t|
    t.integer  "stop_id"
    t.integer  "stop_code"
    t.string   "stop_name"
    t.string   "stop_desc"
    t.string   "stop_lat"
    t.string   "stop_lon"
    t.boolean  "location_type"
    t.integer  "parent_station"
    t.boolean  "wheelchair_boarding"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "users", force: :cascade do |t|
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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "active_steps", "ghost_steps", on_delete: :cascade
  add_foreign_key "ghost_commutes", "commutes", on_delete: :cascade
  add_foreign_key "ghost_steps", "ghost_commutes", on_delete: :cascade
end
