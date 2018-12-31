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

ActiveRecord::Schema.define(version: 20181231031110) do

  create_table "images", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "url"
    t.float "beauty", limit: 24
    t.integer "gender"
    t.integer "age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["current_image_id"], name: "index_users_on_current_image_id"
    t.index ["mixin_id"], name: "index_users_on_mixin_id"
    t.index ["session_key"], name: "index_users_on_session_key"
  end

  add_foreign_key "users", "images", column: "current_image_id"
end
