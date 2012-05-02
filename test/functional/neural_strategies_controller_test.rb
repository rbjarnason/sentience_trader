require File.dirname(__FILE__) + '/../test_helper'

class NeuralStrategiesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:neural_strategies)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_neural_strategy
    assert_difference('NeuralStrategy.count') do
      post :create, :neural_strategy => { }
    end

    assert_redirected_to neural_strategy_path(assigns(:neural_strategy))
  end

  def test_should_show_neural_strategy
    get :show, :id => neural_strategies(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => neural_strategies(:one).id
    assert_response :success
  end

  def test_should_update_neural_strategy
    put :update, :id => neural_strategies(:one).id, :neural_strategy => { }
    assert_redirected_to neural_strategy_path(assigns(:neural_strategy))
  end

  def test_should_destroy_neural_strategy
    assert_difference('NeuralStrategy.count', -1) do
      delete :destroy, :id => neural_strategies(:one).id
    end

    assert_redirected_to neural_strategies_path
  end
end
