require 'httparty'

class RetrievesController < ApplicationController

  def initialize
    @uri = CommuteOptimizer::Application.config.bus_api_uri
    @key = CommuteOptimizer::Application.config.bus_api_key
  end

  def buslines
    # render plain: resource
    request = request_base('routes')
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
    request = request_base('directions')

    buslines.each { |busline|
      route_request = request + request_params({'rt' => busline.rt})
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
    request = request_base('stops')
    stops = Array.new
    busroutes.each { |busroute|
      direction_request = request + request_params({
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
    # https://maps.googleapis.com/maps/api/directions/json?origin=41.840592684542,-87.623230218887&destination=41.994241429331,-87.764899134636&mode=transit&alternatives=true&key=AIzaSyB7IISLr7_ejDrcVm-n-Cht7aTC9KhW-yc
  end

  def prediction
    rt = params[:id]
    stpid = params[:stpid]
    request = request_base('predictions')
    prediction_request = request + request_params({
      :rt => rt,
      :stpid => stpid
      })
    response = HTTParty.get(prediction_request)
    render json: response
  end

  private

    def request_base(resource)
      @uri + 'get' + resource + '?key=' + @key
    end

    def request_params(param_array)
      param_strings = String.new
      param_array.each { |key,val|
        param_string = "\&#{key}=#{val}"
        param_strings << param_string
      }
      param_strings
    end

end
