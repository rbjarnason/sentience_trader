require 'test_helper'

class ClassifiedParagraphsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:classified_paragraphs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create classified_paragraph" do
    assert_difference('ClassifiedParagraph.count') do
      post :create, :classified_paragraph => { }
    end

    assert_redirected_to classified_paragraph_path(assigns(:classified_paragraph))
  end

  test "should show classified_paragraph" do
    get :show, :id => classified_paragraphs(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => classified_paragraphs(:one).id
    assert_response :success
  end

  test "should update classified_paragraph" do
    put :update, :id => classified_paragraphs(:one).id, :classified_paragraph => { }
    assert_redirected_to classified_paragraph_path(assigns(:classified_paragraph))
  end

  test "should destroy classified_paragraph" do
    assert_difference('ClassifiedParagraph.count', -1) do
      delete :destroy, :id => classified_paragraphs(:one).id
    end

    assert_redirected_to classified_paragraphs_path
  end
end
