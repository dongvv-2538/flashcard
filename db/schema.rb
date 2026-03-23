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

ActiveRecord::Schema[7.2].define(version: 2026_03_23_004652) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "card_schedules", force: :cascade do |t|
    t.bigint "card_id", null: false
    t.date "next_review_date", null: false
    t.integer "interval_days", default: 0, null: false
    t.decimal "ease_factor", precision: 4, scale: 2, default: "2.5", null: false
    t.integer "review_count", default: 0, null: false
    t.datetime "last_reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_card_schedules_on_card_id", unique: true
    t.index ["next_review_date"], name: "index_card_schedules_on_next_review_date"
  end

  create_table "cards", force: :cascade do |t|
    t.bigint "deck_id", null: false
    t.text "front", null: false
    t.text "back", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deck_id"], name: "index_cards_on_deck_id"
  end

  create_table "decks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_decks_on_name"
    t.index ["user_id"], name: "index_decks_on_user_id"
  end

  create_table "session_ratings", force: :cascade do |t|
    t.bigint "study_session_id", null: false
    t.bigint "card_id", null: false
    t.integer "rating", null: false
    t.datetime "reviewed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_session_ratings_on_card_id"
    t.index ["rating"], name: "index_session_ratings_on_rating"
    t.index ["study_session_id", "card_id"], name: "index_session_ratings_on_study_session_id_and_card_id"
    t.index ["study_session_id"], name: "index_session_ratings_on_study_session_id"
  end

  create_table "study_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "deck_id", null: false
    t.integer "session_type", default: 0, null: false
    t.datetime "started_at", null: false
    t.datetime "ended_at"
    t.integer "cards_reviewed_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deck_id"], name: "index_study_sessions_on_deck_id"
    t.index ["ended_at"], name: "index_study_sessions_on_ended_at"
    t.index ["session_type"], name: "index_study_sessions_on_session_type"
    t.index ["user_id"], name: "index_study_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "card_schedules", "cards"
  add_foreign_key "cards", "decks"
  add_foreign_key "decks", "users"
  add_foreign_key "session_ratings", "cards"
  add_foreign_key "session_ratings", "study_sessions"
  add_foreign_key "study_sessions", "decks"
  add_foreign_key "study_sessions", "users"
end
