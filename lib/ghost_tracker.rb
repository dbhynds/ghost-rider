require 'rufus-scheduler'

class GhostTracker
  include MapApis
  attr_reader :now, :commutes_now, :active_steps

  def initialize
    @now = Time.now.hour * 3600 + Time.now.min * 60
    # trackActiveCommutes
    # if active_steps
    #   active_steps.each { |step|
    #     trackStep step
    #   }
    # end
    # queueNextSteps
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
        if ghost_commute.ghost_steps.incomplete.count > 0
          ghost_commute.ghost_steps.incomplete.first.track
        end
      }
    end
  end

  def trackStep(active_step)
    case active_step.mode
      when 'WALKING'
        trackWALKING active_step
      when 'SUBWAY'
        trackSUBWAY active_step
      when 'BUS'
    end
    active_step
  end

  def queueNextSteps
    if active_steps
      active_steps.each { |active_step|
        if active_step.ghost_step.completed
          next_steps = active_step.ghost_step.ghost_commute.ghost_steps.incomplete
          if next_steps.count > 0
            next_steps.first.track
          end
          active_step.destroy
        end
      }
    end
  end

  def finishStep(active_step)
    time_now = Time.now.to_i
    elapsed_time = time_now - active_step.start_time.to_i
    active_step.ghost_step.update({ "duration" => elapsed_time, "completed" => true })
    active_step
  end

  def trackWALKING(active_step)
    step_duration = active_step.start_time.to_i + active_step.duration.to_i
    time_now = Time.now.to_i
    if time_now > step_duration
      finishStep active_step
    end
    active_step
  end

  def trackSUBWAY(active_step)
    step_origins = Array.new
    step_origins = Stop
      .where("stop_id > ?", 29999)
      .where("stop_id < ?", 40000)
      .where("stop_lon LIKE ?", "%#{active_step.origin_long.to_d(5).to_s[0...-1]}%")
      .where("stop_lat LIKE ?", "%#{active_step.origin_lat.to_d(5).to_s[0...-1]}%")
      .all
    step_arrivals = Array.new
    # puts "Considering arrivals at #{step_origins.map{|step| step.stop_id}}"
    step_origins.each do |step_origin|
      request = train_request('arrivals',{'stpid' => step_origin.stop_id})
      step_arrival = HTTParty.get(request).parsed_response['ctatt']['eta']
      unless step_arrival.nil?
        step_arrival.delete_if { |train| nil || !train['destNm'].include?(active_step.heading) }
        step_arrivals.push(step_arrival)
      end
    end
    step_arrivals.flatten!
    run = step_arrivals.shift
    # puts "Following run #{run['rn']}"
    active_step.request = train_request('follow',{'runnumber' => run['rn']})
    active_step.watched_vehicles = run['rn']
    train_data = HTTParty.get(active_step.request).parsed_response['ctatt']['eta']
    upcoming_stops = train_data.map { |stop| stop['staNm'] }
    
    if !active_step.arriving_at_origin
      active_step.arriving_at_origin = upcoming_stops.include?(active_step.origin)
    end
    if active_step.arriving_at_origin
      active_step.arrived_at_origin = !upcoming_stops.include?(active_step.origin)
    end
    if active_step.arrived_at_origin && !active_step.arriving_at_dest
      active_step.arriving_at_dest = upcoming_stops.include?(active_step.dest)
    end
    if active_step.arriving_at_dest
      active_step.arrived_at_dest = !upcoming_stops.include?(active_step.dest)
    end

    if active_step.arrived_at_dest
      # puts "Train #{run['rn']} has arrived at #{active_step.dest}!"
      finishStep active_step
    end

    active_step.save
    
  end

end
