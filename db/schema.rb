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

ActiveRecord::Schema.define(version: 20160712024340) do

  create_table "busdirections", force: :cascade do |t|
    t.string   "dir"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "buslines", force: :cascade do |t|
    t.string   "rt"
    t.string   "rtnm"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "buslines", ["rt"], name: "index_buslines_on_rt"

  create_table "busroutes", force: :cascade do |t|
    t.integer  "busline_id"
    t.integer  "busdirection_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "busroutes", ["busdirection_id"], name: "index_busroutes_on_busdirection_id"
  add_index "busroutes", ["busline_id"], name: "index_busroutes_on_busline_id"

  create_table "busroutes_busstops", id: false, force: :cascade do |t|
    t.integer "busroute_id"
    t.integer "busstop_id"
  end

  add_index "busroutes_busstops", ["busroute_id"], name: "index_busroutes_busstops_on_busroute_id"
  add_index "busroutes_busstops", ["busstop_id"], name: "index_busroutes_busstops_on_busstop_id"

  create_table "busstops", force: :cascade do |t|
    t.integer  "stpid"
    t.string   "stpnm"
    t.float    "lat"
    t.float    "lon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "busstops", ["lat"], name: "index_busstops_on_lat"
  add_index "busstops", ["lon"], name: "index_busstops_on_lon"
  add_index "busstops", ["stpid"], name: "index_busstops_on_stpid"
  add_index "busstops", ["stpnm"], name: "index_busstops_on_stpnm"

  create_table "commutes", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "origin"
    t.string   "dest"
    t.string   "departure_time"
    t.float    "origin_lat"
    t.float    "origin_long"
    t.string   "dest_lat"
    t.string   "dest_long"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "commutes", ["user_id"], name: "index_commutes_on_user_id"

  create_table "ghost_commutes", force: :cascade do |t|
    t.integer  "commute_id"
    t.string   "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ghost_commutes", ["commute_id"], name: "index_ghost_commutes_on_commute_id"

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
    t.string   "duration"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "ghost_steps", ["ghost_commute_id"], name: "index_ghost_steps_on_ghost_commute_id"

  create_table "patterns", force: :cascade do |t|
    t.string   "rt"
    t.integer  "pid"
    t.integer  "ln"
    t.string   "rtdir"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "points", force: :cascade do |t|
    t.integer  "ptrid"
    t.integer  "seq"
    t.string   "typ"
    t.integer  "stpid"
    t.string   "sptnm"
    t.float    "pdist"
    t.float    "lat"
    t.float    "lon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "predictions", force: :cascade do |t|
    t.integer  "stpid"
    t.string   "rt"
    t.integer  "vid"
    t.string   "tmstmp"
    t.string   "typ"
    t.string   "stpnm"
    t.integer  "dstp"
    t.string   "rtdir"
    t.string   "des"
    t.string   "prdtm"
    t.boolean  "dly"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "vehicles", force: :cascade do |t|
    t.integer  "route_id"
    t.integer  "vid"
    t.string   "tmstmp"
    t.float    "lat"
    t.float    "lon"
    t.integer  "hdg"
    t.integer  "pid"
    t.integer  "pdist"
    t.string   "des"
    t.boolean  "dly"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "vehicles", ["lat"], name: "index_vehicles_on_lat"
  add_index "vehicles", ["lon"], name: "index_vehicles_on_lon"
  add_index "vehicles", ["route_id"], name: "index_vehicles_on_route_id"
  add_index "vehicles", ["vid"], name: "index_vehicles_on_vid"

end
