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
    assert @ghost_step.active_steps.create!
  end

  test "create an invalid active step" do
    @active_step = ActiveStep.new
    assert @active_step.invalid?
    assert @active_step.errors[:ghost_step].any?
  end

  test "an active step has proper relationships" do
    @active_step = @ghost_step.active_steps.create!
    assert @active_step.ghost_step == @ghost_step
    assert @active_step.ghost_step.ghost_commute == @ghost_commute
    assert @active_step.ghost_step.ghost_commute.ghost_steps.include? @ghost_step
    assert @active_step.ghost_step.ghost_commute.commute == @commute
    assert @active_step.ghost_step.ghost_commute.commute.user == @user
  end

end
