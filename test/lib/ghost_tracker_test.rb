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
      assert_no_difference('GhostCommute.count') do
        @ghost_tracker.trackActiveCommutes
      end
      assert_no_difference('GhostStep.count') do
        @ghost_tracker.trackActiveCommutes
      end
    end
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 00, 00) do
      @ghost_tracker = GhostTracker.new
      assert_difference('ActiveStep.count',6) do
        @ghost_tracker.trackActiveCommutes
      end
      assert_difference('GhostCommute.count',4) do
        @ghost_tracker.trackActiveCommutes
      end
      ghost_step_count = GhostStep.count
      @ghost_tracker.trackActiveCommutes
      assert_operator(GhostStep.count,'>',ghost_step_count)
      assert_operator(GhostStep.count - ghost_step_count,'>=',4)
    end
  end

  test "get active steps" do
    assert_equal @ghost_tracker.active_steps, ActiveStep.all
  end

  test "finish step" do
    active_step = ActiveStep.all.sample
    ghost_step_attr = active_step.ghost_step.attributes
    @ghost_tracker.finishStep active_step
    assert_not_equal active_step.ghost_step.duration, ghost_step_attr[:duration]
    assert_not_equal active_step.ghost_step.completed, ghost_step_attr[:completed]
    assert active_step.ghost_step.completed
  end

  test "track active step" do
    setGhostTrackerAt1700
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 03, 00) do
      @ghost_tracker.active_steps.each do |active_step|
        ghost_step = active_step.ghost_step.attributes
        assert_no_difference('ActiveStep.count') do
          @ghost_tracker.trackStep active_step
        end
      end
    end
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 04, 00) do
      active_step = active_steps(:one)
      ghost_step = active_step.ghost_step.attributes
      @ghost_tracker.trackStep active_step
      assert_not_equal GhostStep.find(ghost_step['id']).duration, ghost_step[:duration]
      assert_not_equal GhostStep.find(ghost_step['id']).completed, ghost_step[:completed]
    end
  end

  test "track walking step" do
    active_step = active_steps(:one)
      ghost_step_attr = active_step.ghost_step.attributes
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 00, 00) do
      active_step.update({start_time: Time.now.to_i})
      @ghost_tracker.trackWALKING active_step
      assert_equal active_step.ghost_step.completed, ghost_step_attr['completed']
    end
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 07, 00) do
      @ghost_tracker.trackWALKING active_step
      assert_not_equal active_step.ghost_step.completed, ghost_step_attr['completed']
    end
  end

  test "queue next step" do
    assert_nothing_raised do
      @ghost_tracker.queueNextSteps
    end
    setGhostTrackerAt1700
    trackStepAt1704
    previous_steps = @ghost_tracker.active_steps.select('id').to_a
    @ghost_tracker.queueNextSteps
    assert_not_equal @ghost_tracker.active_steps.select('id').to_a, previous_steps
  end

  test "next step" do
    setGhostTrackerAt1700
    trackStepAt1704
    @ghost_tracker.queueNextSteps
    travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 05, 00) do
      ghost_step = ghost_steps(:two)
      active_step = ghost_step.active_step
      step_attr = active_step.attributes
      @ghost_tracker.trackStep active_step
      assert_not_equal ActiveStep.find(step_attr['id']).request, step_attr[:request]
      assert_not_equal ActiveStep.find(step_attr['id']).watched_vehicles, step_attr[:watched_vehicles]
    end
  end

  test "track train step" do
    ghost_step = ghost_steps(:train)
    active_step = ghost_step.track
    assert @ghost_tracker.trackSUBWAY active_step
    active_step.arriving_at_origin = true
    assert @ghost_tracker.trackSUBWAY active_step
    active_step.arrived_at_origin = true
    assert @ghost_tracker.trackSUBWAY active_step
    active_step.arriving_at_dest = true
    assert @ghost_tracker.trackSUBWAY active_step
    active_step.arrived_at_dest = true
    assert @ghost_tracker.trackSUBWAY active_step
  end

  test "track bus step" do
    ghost_step = ghost_steps(:bus)
    active_step = ghost_step.track
    assert @ghost_tracker.trackBUS active_step
  end

  private

    def setGhostTrackerAt1700
      travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 00, 00) do
        @ghost_tracker = GhostTracker.new
        @ghost_tracker.trackActiveCommutes
      end
    end

    def trackStepAt1704
      travel_to Time.new(Time.now.year, Time.now.month, Time.now.day, 17, 04, 00) do
        @ghost_tracker.active_steps.each do |active_step|
          @ghost_tracker.trackStep active_step
        end
      end
    end

end
