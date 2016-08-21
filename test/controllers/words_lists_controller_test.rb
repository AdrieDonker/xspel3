require 'test_helper'

class WordsListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @words_list = words_lists(:one)
  end

  test "should get index" do
    get words_lists_url
    assert_response :success
  end

  test "should get new" do
    get new_words_list_url
    assert_response :success
  end

  test "should create words_list" do
    assert_difference('WordsList.count') do
      post words_lists_url, params: { words_list: { description: @words_list.description, group: @words_list.group, name: @words_list.name, words: @words_list.words } }
    end

    assert_redirected_to words_list_url(WordsList.last)
  end

  test "should show words_list" do
    get words_list_url(@words_list)
    assert_response :success
  end

  test "should get edit" do
    get edit_words_list_url(@words_list)
    assert_response :success
  end

  test "should update words_list" do
    patch words_list_url(@words_list), params: { words_list: { description: @words_list.description, group: @words_list.group, name: @words_list.name, words: @words_list.words } }
    assert_redirected_to words_list_url(@words_list)
  end

  test "should destroy words_list" do
    assert_difference('WordsList.count', -1) do
      delete words_list_url(@words_list)
    end

    assert_redirected_to words_lists_url
  end
end
