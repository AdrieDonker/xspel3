require 'test_helper'

class LetterSetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @letter_set = letter_sets(:one)
  end

  test "should get index" do
    get letter_sets_url
    assert_response :success
  end

  test "should get new" do
    get new_letter_set_url
    assert_response :success
  end

  test "should create letter_set" do
    assert_difference('LetterSet.count') do
      post letter_sets_url, params: { letter_set: { letter_amount_points: @letter_set.letter_amount_points, name: @letter_set.name } }
    end

    assert_redirected_to letter_set_url(LetterSet.last)
  end

  test "should show letter_set" do
    get letter_set_url(@letter_set)
    assert_response :success
  end

  test "should get edit" do
    get edit_letter_set_url(@letter_set)
    assert_response :success
  end

  test "should update letter_set" do
    patch letter_set_url(@letter_set), params: { letter_set: { letter_amount_points: @letter_set.letter_amount_points, name: @letter_set.name } }
    assert_redirected_to letter_set_url(@letter_set)
  end

  test "should destroy letter_set" do
    assert_difference('LetterSet.count', -1) do
      delete letter_set_url(@letter_set)
    end

    assert_redirected_to letter_sets_url
  end
end
