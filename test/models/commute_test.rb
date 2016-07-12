require 'test_helper'

class CommuteTest < ActiveSupport::TestCase

  test "instantiate a new commute" do
    assert commute = Commute.new
  end

  test "create an emtpy commute" do
    commute = Commute.new
    assert commute.save
  end

end
