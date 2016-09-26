require 'test_helper'

class CommutesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @user = users(:one)
    sign_in @user
    @commute = commutes(:one)
    @attr = { :user_id => @user.id, :origin => "Harold Washington Library", :dest => "6237 S Langley Ave", :departure_time => 61200, :origin_lat => "41.876153", :origin_long => "-87.627708", :dest_lat => "41.781123", :dest_long => "-87.608366" }
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:commutes)
    assert_equal @user.commutes.to_json, @response.body
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create commute" do
    assert_difference('Commute.count') do
      post :create, commute: @attr
    end

    assert_redirected_to commute_path(assigns(:commute))
  end

  test "should show commute" do
    get :show, id: @commute
    assert_response :success
    assert_equal assigns(:commute).to_json, @response.body
  end

  test "shouldn't show commute belonging to another user" do
    @user = users(:two)
    sign_in @user
    get :show, id: @commute
    assert_response :unauthorized
  end

  test "should edit commute" do
    get :edit, id: @commute
    assert_response :success
    assert_equal assigns(:commute).to_json, @response.body
  end

  test "shouldn't edit commute belonging to another user" do
    @user = users(:two)
    sign_in @user
    get :edit, id: @commute
    assert_response :unauthorized
  end

  test "should update commute" do
    patch :update, id: @commute, commute: {}
    assert_redirected_to commute_path(assigns(:commute))
  end

  test "shouldn't update commute belonging to another user" do
    @user = users(:two)
    sign_in @user
    post :update, id: @commute
    assert_response :unauthorized
  end

  test "should destroy commute" do
    assert_difference('Commute.count', -1) do
      delete :destroy, id: @commute
    end
    assert_redirected_to commutes_path
  end

  test "shouldn't delete commute belonging to another user" do
    @user = users(:two)
    sign_in @user
    delete :destroy, id: @commute
    assert_response :unauthorized
  end

  test "should get ghosts" do
    get :ghosts, id: @commute
    assert_response :success
    assert_equal @commute.ghost_commutes.to_json, @response.body
  end

end
