require File.dirname(__FILE__) + '/../test_helper'

class QuoteTargetsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:quote_targets)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_quote_target
    assert_difference('QuoteTarget.count') do
      post :create, :quote_target => { }
    end

    assert_redirected_to quote_target_path(assigns(:quote_target))
  end

  def test_should_show_quote_target
    get :show, :id => quote_targets(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => quote_targets(:one).id
    assert_response :success
  end

  def test_should_update_quote_target
    put :update, :id => quote_targets(:one).id, :quote_target => { }
    assert_redirected_to quote_target_path(assigns(:quote_target))
  end

  def test_should_destroy_quote_target
    assert_difference('QuoteTarget.count', -1) do
      delete :destroy, :id => quote_targets(:one).id
    end

    assert_redirected_to quote_targets_path
  end
end
