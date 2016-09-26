require 'test_helper'

class GhostCommutesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  
  setup do
    @user = users(:one)
    sign_in @user
    @ghost_commute = ghost_commutes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ghost_commutes)
  end

  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  # test "should create ghost_commute" do
  #   assert_difference('GhostCommute.count') do
  #     post :create, ghost_commute: {  }
  #   end

  #   assert_redirected_to ghost_commute_path(assigns(:ghost_commute))
  # end

  test "should show ghost_commute" do
    get :show, id: @ghost_commute
    assert_response :success
  end

  # test "should get edit" do
  #   get :edit, id: @ghost_commute
  #   assert_response :success
  # end

  # test "should update ghost_commute" do
  #   patch :update, id: @ghost_commute, ghost_commute: {  }
  #   assert_redirected_to ghost_commute_path(assigns(:ghost_commute))
  # end

  test "should destroy ghost_commute" do
    assert_difference('GhostCommute.count', -1) do
      delete :destroy, id: @ghost_commute
    end

    assert_redirected_to ghost_commutes_path
  end
end
