class GhostCommutesController < ApplicationController
  include RouteScheduler, MapApis

  def index
    render json: GhostCommute.all
  end

  def show
    render json: GhostCommute.find(params[:id])
  end

  def track
    @ghost_commute = GhostCommute.find(params[:id])
    tracked_steps = track_steps(@ghost_commute.ghost_steps.to_a)
    puts tracked_steps
    render json: tracked_steps
  end

  def observe
    @ghost_commute = GhostCommute.find(params[:id])
    @ghost_commute.ghost_steps.each do |step|
      puts step
      if step.mode == 'TRANSIT'
        start_time = Time.now.to_i
        origin = step.origin
        dest = step.dest
        heading = step.heading
        puts "start_time: #{start_time}"
        puts "origin: #{origin}"
        puts "dest: #{dest}"
        puts "heading: #{heading}"
        case step.step_type
        when 'BUS'
          puts "Arrivals for #{step.origin}: "
        when 'SUBWAY'
          step_origins = Stop
            .where("stop_name LIKE ?", "%#{origin}%")
            .where("stop_lat LIKE ?", "%#{step.origin_lat.to_d(7).to_s[0...-1]}%")
            .where("stop_lon LIKE ?", "%#{step.origin_long.to_d(7).to_s[0...-1]}%")
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
            puts train_data

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
            puts "arriving_at_dest: #{arriving_at_dest}"
            if arrived_at_dest
              puts "Train #{run['rn']} has arrived at #{dest}!"
              end_time = Time.now.to_i
              duration = end_time - start_time
              step.duration = duration
              step.save
              job.unschedule
            end

          end
          render json: train_data
          return
        end
      end
    end
    # render json: Stop.where("stop_name LIKE ?", "%#{origin}%").last
  end

end
