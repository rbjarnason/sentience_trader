require 'test_helper'

class ClassifiedPersonCategoriesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:classified_person_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create classified_person_category" do
    assert_difference('ClassifiedPersonCategory.count') do
      post :create, :classified_person_category => { }
    end

    assert_redirected_to classified_person_category_path(assigns(:classified_person_category))
  end

  test "should show classified_person_category" do
    get :show, :id => classified_person_categories(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => classified_person_categories(:one).to_param
    assert_response :success
  end

  test "should update classified_person_category" do
    put :update, :id => classified_person_categories(:one).to_param, :classified_person_category => { }
    assert_redirected_to classified_person_category_path(assigns(:classified_person_category))
  end

  test "should destroy classified_person_category" do
    assert_difference('ClassifiedPersonCategory.count', -1) do
      delete :destroy, :id => classified_person_categories(:one).to_param
    end

    assert_redirected_to classified_person_categories_path
  end
end
