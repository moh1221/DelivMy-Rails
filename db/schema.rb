# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_27_000004) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "authentication_sessions", force: :cascade do |t|
    t.string "user_id", limit: 36, null: false
    t.string "token_digest", limit: 64, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_authentication_sessions_on_expires_at"
    t.index ["token_digest"], name: "index_authentication_sessions_on_token_digest", unique: true
    t.index ["user_id"], name: "index_authentication_sessions_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "CatName", limit: 255, null: false
  end

  create_table "delivers", force: :cascade do |t|
    t.integer "request_id", limit: 4, null: false
    t.string "user_id", limit: 255, null: false
    t.integer "status_id", limit: 4, null: false
    t.string "receipt_img", limit: 255
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_id"], name: "index_delivers_on_unique_request_id", unique: true
    t.index ["user_id"], name: "index_delivers_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.integer "request_id", limit: 4, null: false
    t.text "ItemsName", limit: 65535, null: false
    t.text "ItemDescription", limit: 65535, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.integer "request_id", limit: 4, null: false
    t.string "address", limit: 255, null: false
    t.float "Lat", limit: 24, null: false
    t.float "Long", limit: 24, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.string "picture", limit: 255
    t.string "home", limit: 255
    t.string "work", limit: 255
    t.string "user_id", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requests", force: :cascade do |t|
    t.string "user_id", limit: 255, null: false
    t.string "PlaceName", limit: 255, null: false
    t.integer "status_id", limit: 4, null: false
    t.integer "category_id", limit: 4, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "cost", precision: 12, scale: 2
    t.decimal "fees", precision: 12, scale: 2
    t.datetime "delivery_at"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "statuses", force: :cascade do |t|
    t.string "status_info", limit: 255
  end

  create_table "users", id: false, force: :cascade do |t|
    t.string "uuid", limit: 36, null: false
    t.string "email", limit: 255, null: false
    t.string "password_digest", limit: 255, null: false
    t.integer "role", limit: 4, default: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "auth_token"
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uuid"], name: "index_users_on_uuid", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
