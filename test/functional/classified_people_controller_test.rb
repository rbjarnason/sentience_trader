require 'test_helper'

class ClassifiedPeopleControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:classified_people)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create classified_person" do
    assert_difference('ClassifiedPerson.count') do
      post :create, :classified_person => { }
    end

    assert_redirected_to classified_person_path(assigns(:classified_person))
  end

  test "should show classified_person" do
    get :show, :id => classified_people(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => classified_people(:one).to_param
    assert_response :success
  end

  test "should update classified_person" do
    put :update, :id => classified_people(:one).to_param, :classified_person => { }
    assert_redirected_to classified_person_path(assigns(:classified_person))
  end

  test "should destroy classified_person" do
    assert_difference('ClassifiedPerson.count', -1) do
      delete :destroy, :id => classified_people(:one).to_param
    end

    assert_redirected_to classified_people_path
  end
end
