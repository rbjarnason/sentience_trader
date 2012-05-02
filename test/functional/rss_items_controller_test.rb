require File.dirname(__FILE__) + '/../test_helper'

class RssItemsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:rss_items)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_rss_item
    assert_difference('RssItem.count') do
      post :create, :rss_item => { }
    end

    assert_redirected_to rss_item_path(assigns(:rss_item))
  end

  def test_should_show_rss_item
    get :show, :id => rss_items(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => rss_items(:one).id
    assert_response :success
  end

  def test_should_update_rss_item
    put :update, :id => rss_items(:one).id, :rss_item => { }
    assert_redirected_to rss_item_path(assigns(:rss_item))
  end

  def test_should_destroy_rss_item
    assert_difference('RssItem.count', -1) do
      delete :destroy, :id => rss_items(:one).id
    end

    assert_redirected_to rss_items_path
  end
end
