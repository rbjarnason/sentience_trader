require File.dirname(__FILE__) + '/../test_helper'

class ExchangesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:exchanges)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_exchanges
    assert_difference('Exchanges.count') do
      post :create, :exchanges => { }
    end

    assert_redirected_to exchanges_path(assigns(:exchanges))
  end

  def test_should_show_exchanges
    get :show, :id => exchanges(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => exchanges(:one).id
    assert_response :success
  end

  def test_should_update_exchanges
    put :update, :id => exchanges(:one).id, :exchanges => { }
    assert_redirected_to exchanges_path(assigns(:exchanges))
  end

  def test_should_destroy_exchanges
    assert_difference('Exchanges.count', -1) do
      delete :destroy, :id => exchanges(:one).id
    end

    assert_redirected_to exchanges_path
  end
end
