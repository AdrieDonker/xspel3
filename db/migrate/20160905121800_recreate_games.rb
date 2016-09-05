class RecreateGames < ActiveRecord::Migration[5.0]
  create_table "games", force: :cascade do |t|
    t.string   "name"
    t.integer  "owner_id"
    t.integer  "board_id"
    t.integer  "letter_set_id"
    t.integer  "words_list_id"
    t.text     "words_list_groups"
    t.text     "extra_words_lists"
    t.datetime "started"
    t.text     "laid_letters"
    t.text     "stock_letters"
    t.string   "state"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["board_id"], name: "index_games_on_board_id"
    t.index ["letter_set_id"], name: "index_games_on_letter_set_id"
    t.index ["words_list_id"], name: "index_games_on_words_list_id"
  end
end
