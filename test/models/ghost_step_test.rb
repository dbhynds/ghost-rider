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

  test "create a valid ghost step" do
    @ghost_step = GhostStep.new
    assert @ghost_step.invalid?
    assert @ghost_step.errors[:ghost_commute].any?
  end

  test "a ghost step has proper relationships" do
    @ghost_step = @ghost_commute.ghost_steps.create!
    assert @ghost_step.ghost_commute == @ghost_commute
    assert @ghost_commute.ghost_steps.include? @ghost_step
    assert @ghost_step.ghost_commute.commute == @commute
    assert @ghost_step.ghost_commute.commute.user == @user
  end

end
