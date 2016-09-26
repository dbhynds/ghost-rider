require 'test_helper'

class CommuteTest < ActiveSupport::TestCase

  setup do
    @user = users(:one)
    @commute = commutes(:one)
    @attr = {"origin"=>"Harold Washington Library", "dest"=>"6237 S Langley Ave", "departure_time"=>"61200", "origin_lat"=>41.876153, "origin_long"=>-87.627708, "dest_lat"=>"41.781123", "dest_long"=>"-87.608366"}
  end

  test "create a commute" do
    assert @user.commutes.create!
    assert @user.commutes.create! @attr
  end

  test "create an invalid commute" do
    @commute = Commute.new
    assert @commute.invalid?
    assert @commute.errors[:user].any?
  end

  test "a commute belongs to a user" do
    @commute = @user.commutes.create! @attr
    assert @commute.user == @user
    assert @user.commutes.include? @commute
    assert @commute.user.id == @user.id
  end

end
