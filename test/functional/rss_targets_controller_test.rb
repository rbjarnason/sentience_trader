require File.dirname(__FILE__) + '/../test_helper'

class RssTargetsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:rss_targets)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_rss_target
    assert_difference('RssTarget.count') do
      post :create, :rss_target => { }
    end

    assert_redirected_to rss_target_path(assigns(:rss_target))
  end

  def test_should_show_rss_target
    get :show, :id => rss_targets(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => rss_targets(:one).id
    assert_response :success
  end

  def test_should_update_rss_target
    put :update, :id => rss_targets(:one).id, :rss_target => { }
    assert_redirected_to rss_target_path(assigns(:rss_target))
  end

  def test_should_destroy_rss_target
    assert_difference('RssTarget.count', -1) do
      delete :destroy, :id => rss_targets(:one).id
    end

    assert_redirected_to rss_targets_path
  end
end
