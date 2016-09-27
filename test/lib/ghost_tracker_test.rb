require 'test_helper'

class GhostTrackerTest < ActiveSupport::TestCase

  setup do
    @ghost_tracker = GhostTracker.new
  end

  test "get time now" do
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 00, 00) do
      @ghost_tracker = GhostTracker.new
      assert_equal @ghost_tracker.now, 61200
    end
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 00, 30) do
      @ghost_tracker = GhostTracker.new
      assert_equal @ghost_tracker.now, 61200
    end
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 00, 59) do
      @ghost_tracker = GhostTracker.new
      assert_equal @ghost_tracker.now, 61200
    end
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 16, 59, 59) do
      @ghost_tracker = GhostTracker.new
      assert_equal @ghost_tracker.now, 61140
    end
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 01, 00) do
      @ghost_tracker = GhostTracker.new
      assert_equal @ghost_tracker.now, 61260
    end
  end

  test "get trackable commutes by time" do
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 12, 00, 00) do
      @ghost_tracker = GhostTracker.new
      assert_nil @ghost_tracker.commutes_now
    end
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 00, 00) do
      @ghost_tracker = GhostTracker.new
      assert_equal @ghost_tracker.commutes_now, commutes(:one)
    end
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 01, 00) do
      @ghost_tracker = GhostTracker.new
      assert_equal @ghost_tracker.commutes_now, commutes(:two)
    end
  end

  test "track new commutes" do
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 12, 00, 00) do
      @ghost_tracker = GhostTracker.new
      assert_no_difference('ActiveStep.count') do
        @ghost_tracker.trackActiveCommutes
      end
    end
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 00, 00) do
      @ghost_tracker = GhostTracker.new
      assert_difference('ActiveStep.count') do
        @ghost_tracker.trackActiveCommutes
      end
    end
  end

  test "get active steps" do
    assert_equal @ghost_tracker.active_steps, ActiveStep.all
  end

  test "track active step" do
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 00, 00) do
      @ghost_tracker = GhostTracker.new
      @ghost_tracker.trackActiveCommutes
    end
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 03, 00) do
      @ghost_tracker.active_steps.each { |active_step|
        if active_step.start_time
          ghost_step = active_step.ghost_step.attributes
          assert_no_difference('ActiveStep.count') do
            @ghost_tracker.trackStep active_step
          end
          assert_not_equal GhostStep.find(ghost_step['id']).duration, ghost_step[:duration]
        end
      }
    end
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 04, 00) do
      @ghost_tracker.active_steps.each { |active_step|
        if active_step.start_time
          ghost_step = active_step.ghost_step.attributes
          assert_difference('ActiveStep.count', -1) do
            @ghost_tracker.trackStep active_step
          end
          assert_not_equal GhostStep.find(ghost_step['id']).duration, ghost_step[:duration]
        end
      }
    end
  end

end
