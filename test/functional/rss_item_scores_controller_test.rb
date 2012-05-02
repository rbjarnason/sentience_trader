require 'test_helper'

class RssItemScoresControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rss_item_scores)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rss_item_score" do
    assert_difference('RssItemScore.count') do
      post :create, :rss_item_score => { }
    end

    assert_redirected_to rss_item_score_path(assigns(:rss_item_score))
  end

  test "should show rss_item_score" do
    get :show, :id => rss_item_scores(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => rss_item_scores(:one).id
    assert_response :success
  end

  test "should update rss_item_score" do
    put :update, :id => rss_item_scores(:one).id, :rss_item_score => { }
    assert_redirected_to rss_item_score_path(assigns(:rss_item_score))
  end

  test "should destroy rss_item_score" do
    assert_difference('RssItemScore.count', -1) do
      delete :destroy, :id => rss_item_scores(:one).id
    end

    assert_redirected_to rss_item_scores_path
  end
end
