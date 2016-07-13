require 'rufus-scheduler'

module RouteScheduler

  def track_steps (next_steps, previous_steps = [])
    if  @next_step = next_steps.shift
      case @next_step['mode']
      when 'WALKING'
        scheduler = Rufus::Scheduler.new
        walking_counter = 0
        scheduler.in "#{@next_step['duration']}s" do
          puts "Walking completed: #{@next_step}"
          previous_steps.push(@next_step)
          track_steps(next_steps,previous_steps)
        end
        previous_steps
      when 'TRANSIT'
        previous_steps.push(@next_step)
        track_steps(next_steps,previous_steps)
        previous_steps
      end
    else
      previous_steps
    end
  end

end
