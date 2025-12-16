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

ActiveRecord::Schema[7.1].define(version: 2025_12_08_211117) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "complaints", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "ride_id"
    t.string "subject", null: false
    t.text "description", null: false
    t.string "status", default: "open", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ride_id"], name: "index_complaints_on_ride_id"
    t.index ["user_id"], name: "index_complaints_on_user_id"
  end

  create_table "kyc_documents", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "document_type", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_kyc_documents_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "ride_id", null: false
    t.decimal "amount"
    t.string "status"
    t.string "stripe_charge_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ride_id"], name: "index_payments_on_ride_id"
  end

  create_table "rides", force: :cascade do |t|
    t.bigint "rider_id", null: false
    t.bigint "driver_id"
    t.string "pickup"
    t.string "dropoff"
    t.string "status"
    t.decimal "fare"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "pickup_latitude"
    t.decimal "pickup_longitude"
    t.decimal "dropoff_latitude"
    t.decimal "dropoff_longitude"
    t.index ["driver_id"], name: "index_rides_on_driver_id"
    t.index ["rider_id"], name: "index_rides_on_rider_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "plan_type"
    t.decimal "amount", precision: 10, scale: 2
    t.string "status"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_subscription_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "role"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "available", default: false, null: false
    t.boolean "is_admin", default: false, null: false
    t.boolean "approved", default: false, null: false
    t.string "kyc_status", default: "pending"
    t.decimal "current_latitude"
    t.decimal "current_longitude"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "make"
    t.string "model"
    t.string "plate"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "approved", default: false, null: false
    t.index ["user_id"], name: "index_vehicles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "complaints", "rides"
  add_foreign_key "complaints", "users"
  add_foreign_key "kyc_documents", "users"
  add_foreign_key "payments", "rides"
  add_foreign_key "rides", "users", column: "driver_id"
  add_foreign_key "rides", "users", column: "rider_id"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "vehicles", "users"
end
