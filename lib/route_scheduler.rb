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
        
        start_time = Time.now.to_i
        origin = @next_step.origin
        dest = @next_step.dest
        heading = @next_step.heading
        puts "start_time: #{start_time}"
        puts "origin: #{origin}"
        puts "dest: #{dest}"
        puts "heading: #{heading}"

        case @next_step.step_type
        when 'BUS'

          puts "Arrivals for #{@next_step.origin}: "
          previous_steps.push(@next_step)
          track_steps(next_steps,previous_steps)
          @next_step

        when 'SUBWAY'
          step_origins = Stop
            .where("stop_name LIKE ?", "%#{origin}%")
            .where("stop_lat LIKE ?", "%#{@next_step.origin_lat.to_d(7).to_s[0...-1]}%")
            .where("stop_lon LIKE ?", "%#{@next_step.origin_long.to_d(7).to_s[0...-1]}%")
            .all
          step_arrivals = []
          step_origins.each do |step_origin|
            request = train_request('arrivals',{'stpid' => step_origin.stop_id})
            puts request
            step_arrival = HTTParty.get(request).parsed_response['ctatt']['eta']
            unless step_arrival.nil?
              step_arrival.delete_if { |train| nil || train['destNm'] != heading }
              step_arrivals.push(step_arrival).flatten!
            end
          end
          run = step_arrivals.shift
          request = train_request('follow',{'runnumber' => run['rn']})
          train_data = HTTParty.get(request).parsed_response['ctatt']['eta']

          arriving_at_origin = true
          arrived_at_origin = false
          arriving_at_dest = false
          arrived_at_dest = false

          scheduler = Rufus::Scheduler.new
          scheduler.every '1m' do |job|
            train_data = HTTParty.get(request).parsed_response['ctatt']['eta']
            upcoming_stops = train_data.map { |stop| stop['staNm'] }
            puts "Next stop: #{train_data.shift['satNm']}"

            if !arriving_at_origin
              arriving_at_origin = upcoming_stops.include?(origin)
            end
            if arriving_at_origin
              arrived_at_origin = !upcoming_stops.include?(origin)
            end
            if arrived_at_origin && !arriving_at_dest
                arriving_at_dest = upcoming_stops.include?(dest)
            end
            if arriving_at_dest
              arrived_at_dest = !upcoming_stops.include?(dest)
            end
            puts "arriving_at_origin: #{arriving_at_origin}"
            puts "arrived_at_origin: #{arrived_at_origin}"
            puts "arriving_at_dest: #{arriving_at_dest}"
            puts "arrived_at_dest: #{arrived_at_dest}"
            if arrived_at_dest
              puts "Train #{run['rn']} has arrived at #{dest}!"
              end_time = Time.now.to_i
              duration = end_time - start_time
              @next_step.duration = duration
              @next_step.save
              job.unschedule

              previous_steps.push(@next_step)
              track_steps(next_steps,previous_steps)
              return @next_step
            end

          end
        end

      end
    else
      @next_step
    end
  end

  def track_walking
  end

  def track_bus
  end

  def track_train
  end

end
