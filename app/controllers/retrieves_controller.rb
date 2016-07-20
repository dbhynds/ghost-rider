require 'httparty'
require 'rubygems'
require 'zip'
require 'csv'

class RetrievesController < ApplicationController
  include MapApis

  def initialize
    @uri = CommuteOptimizer::Application.config.bus_api_uri
    @key = CommuteOptimizer::Application.config.bus_api_key
  end

  def all_cta_data
    # http://www.transitchicago.com/downloads/sch_data/google_transit.zip
    puts 'Downloading google_transit.zip'
    input = HTTParty.get("http://www.transitchicago.com/downloads/sch_data/google_transit.zip").body
    puts 'Unzipping...'
    Zip::InputStream.open(StringIO.new(input)) do |io|
      while entry = io.get_next_entry
        case entry.name
        when 'routes.txt'
          puts 'Importing routes.txt'
          routes_csv = entry.get_input_stream.read
          routes = CSV.parse(routes_csv)
          keys = 'route_id,route_short_name,route_long_name,route_type,route_url,route_color,route_text_color'.split(',')
          routes.drop(1).each do |line|
            route = Route.find_or_create_by([keys,line].transpose.to_h)
            puts "Route: #{route}"
          end
        when 'stops.txt'
          puts 'Importing stops.txt'
          stops_csv = entry.get_input_stream.read
          stops = CSV.parse(stops_csv)
          keys = 'stop_id,stop_code,stop_name,stop_desc,stop_lat,stop_lon,location_type,parent_station,wheelchair_boarding'.split(',')
          stops.drop(1).each do |line|
            stop = Stop.find_or_create_by([keys,line].transpose.to_h)
            puts "Stop: #{stop}"
          end
        end
      end
    end
    render plain: 'Done!'
  end

  def buslines
    # render plain: resource
    request = bus_request('routes')
    response = HTTParty.get(request)
    buslines = response['bustime_response']['route']
    if buslines.kind_of?(Hash)
      buslines = [buslines]
    end
    buslines.each { |busline|
      busline.delete('rtclr')
      new_line = Busline.find_or_create_by(busline)
      new_line.save
    }
    render json: Busline.all
  end

  def busdirections
    buslines = Busline.all

    buslines.each { |busline|
      route_request = bus_request('directions',{'rt' => busline.rt})
      response = HTTParty.get(route_request)
      busdirections = response['bustime_response']['dir']
      if !busdirections.kind_of?(Array)
        busdirections = [busdirections]
      end
      busdirections.each { |busdirection|
        busdirection = Busdirection.find_or_create_by({:dir => busdirection})
        if !busline.busdirections.exists?(busdirection)
          busline.busdirections << busdirection
        end
      }
    }
    render json: Busroute.all
  end

  def busstops
    busroutes = Busroute.all
    stops = Array.new
    busroutes.each { |busroute|
      direction_request = bus_request('stops',{
        :rt => busroute.busline.rt,
        :dir => busroute.busdirection.dir
        })
      response = HTTParty.get(direction_request)
      busstops = response['bustime_response']['stop']
      if !busstops.kind_of?(Array)
        busstops = [busstops]
      end
      busstops.each { |busstop|
        busstop = Busstop.find_or_create_by(busstop)
        if !busroute.busstops.exists?(busstop)
          busroute.busstops << busstop
        end
      }
    }
    render json: Busstop.all

    # stops = Array.new
    # busdirections.each { |busdirection|
    #   direction_request = request + request_params({
    #     :rt => busdirection.rt,
    #     :dir => busdirection.dir
    #     })
    #   response = HTTParty.get(direction_request)
    #   response_stops = response['bustime_response']['stop']
    #   if !response_stops.kind_of?(Array)
    #     response_stops = [response_stops]
    #   end
    #   response_stops.each { |stop|
    #     stop[:rt] = busdirection.rt
    #     stop[:dir] = busdirection.dir
    #     Stop.find_or_create_by(stop)
    #     stops.push(stop)
    #   }
    # }
    # render json: stops
  end

  def route
    # https://maps.googleapis.com/maps/api/directions/json?origin=41.954288131006,-87.675206065178&destination=41.780420933475,-87.606294751167&mode=transit&alternatives=true&key=AIzaSyB7IISLr7_ejDrcVm-n-Cht7aTC9KhW-yc
  end

  def prediction
    rt = params[:id]
    stpid = params[:stpid]
    prediction_request = bus_reqeust('predictions',{
      :rt => rt,
      :stpid => stpid
      })
    response = HTTParty.get(prediction_request)
    render json: response
  end

end
