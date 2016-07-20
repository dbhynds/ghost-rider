require 'rufus-scheduler'

module RouteScheduler
  include MapApis

  def track_next_steps(steps)
    @next_steps = steps
    next_step()
  end

  def track_step
    case @next_step['mode']
      when 'WALKING'

        track_walking()

      when 'TRANSIT'
        
        @start_time = Time.now.to_i
        @origin = @next_step.origin
        @dest = @next_step.dest
        @heading = @next_step.heading
        puts "@start_time: #{@start_time}"
        puts "@origin: #{@origin}"
        puts "@dest: #{@dest}"
        puts "@heading: #{@heading}"

        case @next_step.step_type
        when 'BUS'

          track_bus()

        when 'SUBWAY'
          
          track_train()

        end

      end

  end

  def next_step
    if  @next_step = @next_steps.shift
      track_step()
    else
      puts "Arrived at final destination!"
      @next_step
    end
  end

  def track_walking
    scheduler = Rufus::Scheduler.new
    puts "Walking for #{@next_step['duration']} seconds"
    scheduler.in "#{@next_step['duration']}s" do
      puts "Walking completed: #{@next_step}"
      next_step()
    end
    @next_step
  end

  def track_bus

    step_origins = Stop
      .where("stop_lat LIKE ?", "%#{@next_step.origin_lat.to_d(7).to_s[0...-1]}%")
      .where("stop_lon LIKE ?", "%#{@next_step.origin_long.to_d(7).to_s[0...-1]}%")
      .all

    step_destinations = Stop
      .where("stop_lat LIKE ?", "%#{@next_step.dest_lat.to_d(7).to_s[0...-1]}%")
      .where("stop_lon LIKE ?", "%#{@next_step.dest_long.to_d(7).to_s[0...-1]}%")
      .select('stop_id').all.to_a.map { |step| step['stop_id'].to_s }
    puts "Acceptable destination ids: #{step_destinations}"

    step_arrivals = Array.new
    step_origins.each do |step_origin|

      arriving_buses = false
      watched_bus = false
      approaching_dest = false

      scheduler = Rufus::Scheduler.new
      scheduler.every '1m', :first_in => '0s', :times => 180 do |job|

        puts "#{arriving_buses}"
        puts "#{watched_bus}"

        if !arriving_buses
          request = bus_request('predictions',{'stpid' => step_origin.stop_id})
          step_predictions = HTTParty.get(request).parsed_response['bustime_response']['prd']
          unless step_predictions.nil?
            if step_predictions.is_a?(Hash)
              step_predictions = [step_predictions]
            end
            step_predictions.delete_if{ |bus| nil || bus['des'] != @heading }
            step_arrivals.push(step_predictions).flatten!
          end
          if step_arrivals.length
            earliest_bus = step_arrivals.first
            time_now = DateTime.now
            earliest_arrival = DateTime.strptime(earliest_bus['prdtm'],'%Y%m%d %H:%M') - time_now.offset
            time_dif = (earliest_arrival.to_i - time_now.to_i)
            puts "Next bus in: #{time_dif}"
            if (time_dif < 300)
              arriving_buses = step_arrivals.map { |prediction| prediction['vid'] }
              arriving_buses.uniq!
              puts "Watching buses: #{arriving_buses.join(', ')}"
            end
          end
        end

        if arriving_buses && !watched_bus
          
          request = bus_request('predictions',{'vid' => arriving_buses[0..9].join(',')})
          watched_buses = HTTParty.get(request).parsed_response['bustime_response']['prd']
          if watched_buses.is_a?(Hash)
            watched_buses = [watched_buses]
          end
          if watched_buses && watched_buses.length
            approaching_origin = watched_buses.map do |stop|
              if stop['stpnm'] == @origin && stop['des'] == @heading
                stop['vid']
              else
                false
              end
            end
            approaching_origin.delete_if { |vid| !vid }
            arrived_at_origin = arriving_buses - approaching_origin
            if arrived_at_origin.length > 0
              watched_bus = arrived_at_origin.shift
              arriving_buses = Array.new
              puts "Watching bus: #{watched_bus}"
            end
          end
        end

        if watched_bus 
          request = bus_request('predictions',{'vid' => watched_bus})
          watched_predictions = HTTParty.get(request).parsed_response['bustime_response']['prd']
          upcoming_stops = watched_predictions.map do |stop|
            if stop['stpid'] && stop['des'] == @heading
              stop['stpid']
            else
              false
            end
          end
          upcoming_stops.delete_if { |vid| !vid }

          if !approaching_dest
            if !(upcoming_stops & step_destinations).empty?
              approaching_dest = true
              puts "Bus #{watched_bus} is approaching #{@dest}"
            end
          end
          if approaching_dest
            if (upcoming_stops & step_destinations).empty?
              job.unschedule
              end_time = Time.now.to_i
              puts "#{watched_bus} has arrived at #{@dest}"
              duration = end_time - @start_time
              @next_step.duration = duration
              @next_step.save
              next_step()
            end
          end # if approaching_dest

        end # if watched_bus 

      end
      
    end
    @next_step

  end

  def track_train
    step_origins = Stop
      .where("stop_code IS NULL")
      .where("stop_lat LIKE ?", "%#{@next_step.origin_lat.to_d(5).to_s[0...-1]}%")
      .where("stop_lon LIKE ?", "%#{@next_step.origin_long.to_d(5).to_s[0...-1]}%")
      .all
    step_arrivals = Array.new
    puts "Considering arrivals at #{step_origins.map{|step| step.stop_id}}"
    step_origins.each do |step_origin|
      request = train_request('arrivals',{'stpid' => step_origin.stop_id})
      step_arrival = HTTParty.get(request).parsed_response['ctatt']['eta']
      unless step_arrival.nil?
        step_arrival.delete_if { |train| nil || !train['destNm'].include?(@heading) }
        step_arrivals.push(step_arrival)
      end
    end
    step_arrivals.flatten!
    run = step_arrivals.shift
    puts "Following run #{run['rn']}"
    request = train_request('follow',{'runnumber' => run['rn']})
    train_data = HTTParty.get(request).parsed_response['ctatt']['eta']

    arriving_at_origin = true
    arrived_at_origin = false
    arriving_at_dest = false
    arrived_at_dest = false

    scheduler = Rufus::Scheduler.new
    scheduler.every '1m', :times => 180 do |job|
      train_data = HTTParty.get(request).parsed_response['ctatt']['eta']
      upcoming_stops = train_data.map { |stop| stop['staNm'] }
      puts "Next stop: #{train_data.first}"

      if !arriving_at_origin
        arriving_at_origin = upcoming_stops.include?(@origin)
      end
      if arriving_at_origin
        arrived_at_origin = !upcoming_stops.include?(@origin)
      end
      if arrived_at_origin && !arriving_at_dest
          arriving_at_dest = upcoming_stops.include?(@dest)
      end
      if arriving_at_dest
        arrived_at_dest = !upcoming_stops.include?(@dest)
      end
      puts "arriving_at_origin: #{arriving_at_origin}"
      puts "arrived_at_origin: #{arrived_at_origin}"
      puts "arriving_at_dest: #{arriving_at_dest}"
      puts "arrived_at_dest: #{arrived_at_dest}"
      if arrived_at_dest
        job.unschedule
        puts "Train #{run['rn']} has arrived at #{@dest}!"
        end_time = Time.now.to_i
        duration = end_time - @start_time
        @next_step.duration = duration
        @next_step.save

        next_step()
      end

    end
    @next_step
  end

end
