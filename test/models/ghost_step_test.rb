require 'test_helper'

class GhostStepTest < ActiveSupport::TestCase

  setup do
    @user = users(:one)
    @commute = commutes(:one)
    @ghost_commute = ghost_commutes(:one)
    @ghost_step = ghost_steps(:one)
  end

  test "create a ghost step" do
    assert @ghost_commute.ghost_steps.create!
  end

  test "create an invalid ghost step" do
    @ghost_step = GhostStep.new
    assert @ghost_step.invalid?
    assert @ghost_step.errors[:ghost_commute].any?
  end

  test "a ghost step has proper relationships" do
    @ghost_step = @ghost_commute.ghost_steps.create!
    @active_step = @ghost_step.build_active_step(:start_time => Time.now.to_i)
    assert_equal @ghost_step.ghost_commute, @ghost_commute
    assert @ghost_commute.ghost_steps.include? @ghost_step
    assert_equal @ghost_step.ghost_commute.commute, @commute
    assert_equal @ghost_step.ghost_commute.commute.user, @user
    assert_equal @ghost_step.active_step, @active_step
  end

  test "track a ghost step" do
    @ghost_step = @ghost_commute.ghost_steps.create!
    assert_difference('ActiveStep.count') do
      @active_step = @ghost_step.track
      assert_equal @active_step.ghost_step, @ghost_step
    end
  end

end
