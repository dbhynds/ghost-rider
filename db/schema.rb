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

ActiveRecord::Schema.define(version: 20160710003538) do

  create_table "directions", force: :cascade do |t|
    t.string   "rt"
    t.string   "dir"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patterns", force: :cascade do |t|
    t.integer  "pid"
    t.string   "rt"
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

  create_table "routes", force: :cascade do |t|
    t.string   "rt"
    t.string   "rtnm"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stops", force: :cascade do |t|
    t.string   "rt"
    t.string   "dir"
    t.integer  "stpid"
    t.string   "stpnm"
    t.float    "lat"
    t.float    "lon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vehicles", force: :cascade do |t|
    t.string   "rt"
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

end
