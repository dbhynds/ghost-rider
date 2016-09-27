require 'rufus-scheduler'

class GhostTracker
  include MapApis
  attr_reader :now, :commutes_now, :active_steps

  def initialize
    @now = Time.now.hour * 3600 + Time.now.min * 60
  end


  def now
    @now
  end

  def commutes_now
    @commutes_now = Commute.find_by departure_time: @now
  end

  def active_steps
    @active_steps = ActiveStep.all
  end


  def trackActiveCommutes
    if commutes_now
      commutes_now.ghost_commutes.each { |ghost_commute|
        if ghost_commute.ghost_steps.first
          ghost_commute.ghost_steps.first.track
        end
      }
    end
  end

  def trackStep(active_step)
    case
      when active_step.mode == 'WALKING'
        step_duration = active_step.start_time.to_i + active_step.duration.to_i
        time_now = Time.now.to_i
        if time_now > step_duration
          elapsed_time = time_now - active_step.start_time.to_i
          active_step.ghost_step.duration = elapsed_time
          active_step.delete
        end
    end
  end

end
