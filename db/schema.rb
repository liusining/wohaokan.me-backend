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

ActiveRecord::Schema.define(version: 20190103104234) do

  create_table "images", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "url"
    t.float "beauty", limit: 24
    t.integer "gender"
    t.integer "age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "s3_key"
    t.boolean "verified"
    t.string "biz_token", limit: 50
    t.string "image_no", limit: 30
    t.string "verify_msg"
    t.boolean "using"
    t.index ["biz_token"], name: "index_images_on_biz_token", unique: true
    t.index ["user_id"], name: "index_images_on_user_id"
  end

  create_table "orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.bigint "issuer_id"
    t.bigint "endpoint_id"
    t.string "trace_id"
    t.boolean "is_paid", default: false
    t.boolean "contact_given"
    t.boolean "money_delivered"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "delivery_trace_id"
    t.string "conversation_id"
    t.string "message_id"
    t.index ["endpoint_id"], name: "index_orders_on_endpoint_id"
    t.index ["issuer_id"], name: "index_orders_on_issuer_id"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "session_key", limit: 30
    t.string "avatar_url", default: ""
    t.string "mixin_name"
    t.string "nickname"
    t.string "description", default: ""
    t.integer "mixin_id"
    t.bigint "current_image_id"
    t.string "access_token", limit: 500
    t.string "pin_token", default: ""
    t.string "scope", default: ""
    t.string "session_id", limit: 40
    t.string "mixin_uid", limit: 40
    t.integer "age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uid", limit: 30
    t.index ["current_image_id"], name: "index_users_on_current_image_id"
    t.index ["mixin_id"], name: "index_users_on_mixin_id"
    t.index ["session_key"], name: "index_users_on_session_key"
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "images", "users"
  add_foreign_key "orders", "users", column: "endpoint_id"
  add_foreign_key "orders", "users", column: "issuer_id"
  add_foreign_key "users", "images", column: "current_image_id"
end
