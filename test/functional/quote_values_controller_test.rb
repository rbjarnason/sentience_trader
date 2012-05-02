require File.dirname(__FILE__) + '/../test_helper'

class QuoteValuesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:quote_values)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_quote_value
    assert_difference('QuoteValue.count') do
      post :create, :quote_value => { }
    end

    assert_redirected_to quote_value_path(assigns(:quote_value))
  end

  def test_should_show_quote_value
    get :show, :id => quote_values(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => quote_values(:one).id
    assert_response :success
  end

  def test_should_update_quote_value
    put :update, :id => quote_values(:one).id, :quote_value => { }
    assert_redirected_to quote_value_path(assigns(:quote_value))
  end

  def test_should_destroy_quote_value
    assert_difference('QuoteValue.count', -1) do
      delete :destroy, :id => quote_values(:one).id
    end

    assert_redirected_to quote_values_path
  end
end
