require 'test_helper'

class GhostCommuteTest < ActiveSupport::TestCase

  test "instantiate a new ghost commute" do
    assert ghost_commute = GhostCommute.new
  end

  test "create an emtpy ghost commute" do
    ghost_commute = GhostCommute.new
    assert ghost_commute.save
  end

  test "a ghost commute belongs to a commute" do
    commute = Commute.new.save
    assert GhostCommute.create({'commute' => commute})
  end
  
end
