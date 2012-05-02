require File.dirname(__FILE__) + '/../test_helper'

class NeuralPopulationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:neural_populations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_neural_population
    assert_difference('NeuralPopulation.count') do
      post :create, :neural_population => { }
    end

    assert_redirected_to neural_population_path(assigns(:neural_population))
  end

  def test_should_show_neural_population
    get :show, :id => neural_populations(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => neural_populations(:one).id
    assert_response :success
  end

  def test_should_update_neural_population
    put :update, :id => neural_populations(:one).id, :neural_population => { }
    assert_redirected_to neural_population_path(assigns(:neural_population))
  end

  def test_should_destroy_neural_population
    assert_difference('NeuralPopulation.count', -1) do
      delete :destroy, :id => neural_populations(:one).id
    end

    assert_redirected_to neural_populations_path
  end
end
