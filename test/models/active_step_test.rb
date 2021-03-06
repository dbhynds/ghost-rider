require 'test_helper'

class ActiveStepTest < ActiveSupport::TestCase

  setup do
    @user = users(:one)
    @commute = commutes(:one)
    @ghost_commute = ghost_commutes(:one)
    @ghost_step = ghost_steps(:one)
    @active_step = active_steps(:one)
  end

  test "create an active step" do
    assert @ghost_step.build_active_step
  end

  test "create an invalid active step" do
    @active_step = ActiveStep.new
    assert @active_step.invalid?
    assert @active_step.errors[:ghost_step].any?
  end

  test "an active step has proper relationships" do
    @active_step = @ghost_step.build_active_step
    assert_equal @active_step.ghost_step, @ghost_step
    assert_equal @active_step.ghost_step.ghost_commute, @ghost_commute
    assert @active_step.ghost_step.ghost_commute.ghost_steps.include? @ghost_step
    assert_equal @active_step.ghost_step.ghost_commute.commute, @commute
    assert_equal @active_step.ghost_step.ghost_commute.commute.user, @user
    assert_equal @ghost_step.active_step, @active_step
  end

  test "an active step has a mode" do
    mode = (@ghost_step.mode == 'WALKING') ? @ghost_step.mode : @ghost_step.step_type
    assert_equal @active_step.mode, mode
    
    @ghost_step = ghost_steps(:two)
    mode = (@ghost_step.mode == 'WALKING') ? @ghost_step.mode : @ghost_step.step_type
    @active_step = active_steps(:two)
    assert_equal @active_step.mode, mode
  end

  test "active step has attributes of ghost step" do
    assert_equal @active_step.origin, @ghost_step.origin
    assert_equal @active_step.destination, @ghost_step.dest
    assert_equal @active_step.origin_lat, @ghost_step.origin_lat
    assert_equal @active_step.origin_long, @ghost_step.origin_long
    assert_equal @active_step.dest_lat, @ghost_step.dest_lat
    assert_equal @active_step.dest_long, @ghost_step.dest_long
    assert_equal @active_step.duration, @ghost_step.duration
    assert_equal @active_step.heading, @ghost_step.heading
  end

end
