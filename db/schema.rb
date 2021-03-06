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

ActiveRecord::Schema.define(version: 20160315021203) do

  create_table "categories", force: :cascade do |t|
    t.string "CatName", limit: 255, null: false
  end

  create_table "delivers", force: :cascade do |t|
    t.integer  "request_id",   limit: 4,   null: false
    t.string   "user_id",      limit: 255, null: false
    t.integer  "status_id",    limit: 4,   null: false
    t.string   "receipt_img",  limit: 255
    t.datetime "completed_at"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "delivers", ["request_id"], name: "index_delivers_on_request_id"

  create_table "items", force: :cascade do |t|
    t.integer  "request_id",      limit: 4,     null: false
    t.text     "ItemsName",       limit: 65535, null: false
    t.text     "ItemDescription", limit: 65535, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "locations", force: :cascade do |t|
    t.integer  "request_id", limit: 4,   null: false
    t.string   "address",    limit: 255, null: false
    t.float    "Lat",        limit: 24,  null: false
    t.float    "Long",       limit: 24,  null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.string   "picture",    limit: 255
    t.string   "home",       limit: 255
    t.string   "work",       limit: 255
    t.string   "user_id",    limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "requests", force: :cascade do |t|
    t.string   "user_id",     limit: 255,                null: false
    t.string   "PlaceName",   limit: 255,                null: false
    t.integer  "status_id",   limit: 4,                  null: false
    t.integer  "category_id", limit: 4,                  null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.decimal  "cost",                    precision: 10
    t.decimal  "fees",                    precision: 10
    t.datetime "delivery_at"
  end

  create_table "statuses", force: :cascade do |t|
    t.string "status_info", limit: 255
  end

  create_table "users", id: false, force: :cascade do |t|
    t.string   "uuid",                   limit: 36,              null: false
    t.string   "email",                  limit: 255,             null: false
    t.string   "password_digest",        limit: 255,             null: false
    t.integer  "role",                   limit: 4,   default: 2, null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["uuid"], name: "index_users_on_uuid", unique: true

end
