require 'test_helper'

class ClassificationStrategiesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:classification_strategies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create classification_strategy" do
    assert_difference('ClassificationStrategy.count') do
      post :create, :classification_strategy => { }
    end

    assert_redirected_to classification_strategy_path(assigns(:classification_strategy))
  end

  test "should show classification_strategy" do
    get :show, :id => classification_strategies(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => classification_strategies(:one).id
    assert_response :success
  end

  test "should update classification_strategy" do
    put :update, :id => classification_strategies(:one).id, :classification_strategy => { }
    assert_redirected_to classification_strategy_path(assigns(:classification_strategy))
  end

  test "should destroy classification_strategy" do
    assert_difference('ClassificationStrategy.count', -1) do
      delete :destroy, :id => classification_strategies(:one).id
    end

    assert_redirected_to classification_strategies_path
  end
end
