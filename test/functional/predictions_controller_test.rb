require File.dirname(__FILE__) + '/../test_helper'

class PredictionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:predictions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_prediction
    assert_difference('Prediction.count') do
      post :create, :prediction => { }
    end

    assert_redirected_to prediction_path(assigns(:prediction))
  end

  def test_should_show_prediction
    get :show, :id => predictions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => predictions(:one).id
    assert_response :success
  end

  def test_should_update_prediction
    put :update, :id => predictions(:one).id, :prediction => { }
    assert_redirected_to prediction_path(assigns(:prediction))
  end

  def test_should_destroy_prediction
    assert_difference('Prediction.count', -1) do
      delete :destroy, :id => predictions(:one).id
    end

    assert_redirected_to predictions_path
  end
end
