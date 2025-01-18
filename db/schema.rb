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

ActiveRecord::Schema[7.1].define(version: 2025_01_18_002940) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "challenges", force: :cascade do |t|
    t.string "title", null: false
    t.string "description", null: false
    t.string "tags", default: [], array: true
    t.string "difficulty", null: false
    t.string "image_banner"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sample_image", default: "/assets/challenges/chicken-alfredo-a8818b7ed0ba0a94f92286159894470f583b2366fc03833a11b66f5c8db92afb.jpeg", null: false
    t.integer "order_ids", default: [], null: false, array: true
    t.string "color_codes", default: "/* red */\nrgba(255, 0, 0, 1)\n/* green */\nrgba(0, 255, 0, 1)\n/* blue */\nrgba(0, 0, 255, 1)", null: false
    t.index ["user_id"], name: "index_challenges_on_user_id"
    t.check_constraint "difficulty::text = ANY (ARRAY['easy'::character varying, 'medium'::character varying, 'hard'::character varying]::text[])", name: "difficulty_check"
  end

  create_table "orders", force: :cascade do |t|
    t.string "customer_name", null: false
    t.integer "timeline", default: 360, null: false
    t.string "message", default: "", null: false
    t.bigint "challenge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_id"], name: "index_orders_on_challenge_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "score", default: 0, null: false
    t.string "challenge_ids", default: [], null: false, array: true
  end

  add_foreign_key "challenges", "users"
  add_foreign_key "orders", "challenges"
end
