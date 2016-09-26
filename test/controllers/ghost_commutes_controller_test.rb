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

  test "should show ghost_commute" do
    get :show, id: @ghost_commute
    assert_response :success
  end

  test "should destroy ghost_commute" do
    assert_difference('GhostCommute.count', -1) do
      delete :destroy, id: @ghost_commute
    end

    assert_redirected_to ghost_commutes_path
  end
end
