require 'test_helper'

class GhostCommuteTest < ActiveSupport::TestCase

  setup do
    @user = users(:one)
    @commute = commutes(:one)
    @ghost_commute = ghost_commutes(:one)
  end

  test "create a ghost commute" do
    assert @commute.ghost_commutes.create!
  end

  test "create an invalid ghost commute" do
    @ghost_commute = GhostCommute.new
    assert @ghost_commute.invalid?
    assert @ghost_commute.errors[:commute].any?
  end

  test "a ghost commute belongs to a commute" do
    @ghost_commute = @commute.ghost_commutes.create!
    assert @ghost_commute.commute == @commute
    assert @commute.ghost_commutes.include? @ghost_commute
    assert @ghost_commute.commute.id == @commute.id
    assert @ghost_commute.commute.user == @user
  end
  
end
