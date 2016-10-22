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

ActiveRecord::Schema.define(version: 20161019175706) do

  create_table "boards", force: :cascade do |t|
    t.string   "name"
    t.text     "layout"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gamers", force: :cascade do |t|
    t.integer  "game_id"
    t.integer  "user_id"
    t.integer  "sequence_nbr"
    t.integer  "score"
    t.string   "state"
    t.integer  "position"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["game_id"], name: "index_gamers_on_game_id"
    t.index ["user_id"], name: "index_gamers_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string   "name"
    t.integer  "owner_id"
    t.integer  "board_id"
    t.integer  "letter_set_id"
    t.integer  "words_list_id"
    t.text     "words_list_groups"
    t.text     "extra_words_lists"
    t.datetime "started_at"
    t.text     "laid_letters"
    t.text     "stock_letters"
    t.string   "state"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "invited_at"
    t.integer  "invite_time"
    t.integer  "play_time"
    t.index ["board_id"], name: "index_games_on_board_id"
    t.index ["letter_set_id"], name: "index_games_on_letter_set_id"
    t.index ["words_list_id"], name: "index_games_on_words_list_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "letter_sets", force: :cascade do |t|
    t.string   "name"
    t.text     "letter_amount_points"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string   "name"
    t.integer  "max_invite_hours"
    t.integer  "max_play_hours"
    t.integer  "extra_on_bingo"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "turns", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "score"
    t.integer  "sequence_nbr"
    t.boolean  "bingo"
    t.string   "state"
    t.text     "start_letters"
    t.text     "end_letters"
    t.datetime "started"
    t.datetime "ended"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "words"
    t.integer  "gamer_id"
    t.text     "laid_letters"
    t.index ["game_id"], name: "index_turns_on_game_id"
    t.index ["user_id"], name: "index_turns_on_user_id"
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
    t.string   "name"
    t.integer  "role"
    t.string   "locale"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "words_lists", force: :cascade do |t|
    t.string   "name"
    t.string   "group"
    t.string   "description"
    t.text     "words"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end
