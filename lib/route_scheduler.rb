require 'rufus-scheduler'

module RouteScheduler

  def track_steps (next_steps, previous_steps = [])
    if  @next_step = next_steps.shift
      case @next_step['mode']
      when 'WALKING'
        scheduler = Rufus::Scheduler.new
        scheduler.in "#{@next_step['duration']}s" do
          puts "Walking completed: #{@next_step}"
          previous_steps.push(@next_step)
          track_steps(next_steps,previous_steps)
        end
        @next_step
      when 'TRANSIT'
        # scheduler = Rufus::Scheduler.new
        # scheduler.every '1m' do |job|
        #   case @next_step['step_type']
        #   when 'BUS'
        #   when 'SUBWAY'
        #   end
        #   if step_completed
        #     job.unschedule
        #     previous_steps.push(@next_step)
        #     track_steps(next_steps,previous_steps)
        #   end
        # end
        previous_steps.push(@next_step)
        track_steps(next_steps,previous_steps)
        @next_step
      end
    else
      @next_step
    end
  end

end
