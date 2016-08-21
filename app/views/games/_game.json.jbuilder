json.extract! game, :id, :name, :board_id, :letter_set_id, :words_list_id, :words_list_groups, :extra_words_lists, :text, :created_at, :updated_at
json.url game_url(game, format: :json)