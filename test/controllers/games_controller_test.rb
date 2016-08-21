require 'test_helper'

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game = games(:one)
  end

  test "should get index" do
    get games_url
    assert_response :success
  end

  test "should get new" do
    get new_game_url
    assert_response :success
  end

  test "should create game" do
    assert_difference('Game.count') do
      post games_url, params: { game: { board_id: @game.board_id, extra_words_lists: @game.extra_words_lists, letter_set_id: @game.letter_set_id, name: @game.name, text: @game.text, words_list_groups: @game.words_list_groups, words_list_id: @game.words_list_id } }
    end

    assert_redirected_to game_url(Game.last)
  end

  test "should show game" do
    get game_url(@game)
    assert_response :success
  end

  test "should get edit" do
    get edit_game_url(@game)
    assert_response :success
  end

  test "should update game" do
    patch game_url(@game), params: { game: { board_id: @game.board_id, extra_words_lists: @game.extra_words_lists, letter_set_id: @game.letter_set_id, name: @game.name, text: @game.text, words_list_groups: @game.words_list_groups, words_list_id: @game.words_list_id } }
    assert_redirected_to game_url(@game)
  end

  test "should destroy game" do
    assert_difference('Game.count', -1) do
      delete game_url(@game)
    end

    assert_redirected_to games_url
  end
end
