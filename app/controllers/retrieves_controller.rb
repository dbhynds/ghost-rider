require 'httparty'

class RetrievesController < ApplicationController

  def initialize
    @uri = CommuteOptimizer::Application.config.bus_api_uri
    @key = CommuteOptimizer::Application.config.bus_api_key
  end

  def routes
    # render plain: resource
    request = request_base('routes')
    response = HTTParty.get(request)
    routes = response['bustime_response']['route']
    routes.each { |route|
      route.delete('rtclr')
      new_route = Route.find_or_create_by(route)
      new_route.save
    }
    render json: routes
  end

  def directions
    routes = Route.all
    request = request_base('directions')
    directions = Array.new
    routes.each { |route|
      route_request = request + request_params({'rt' => route.rt})
      response = HTTParty.get(route_request)
      dirs = response['bustime_response']['dir']
      if dirs.kind_of?(Hash)
        dirs = [dirs]
      end
      dirs.each { |dir|
        direction = {'rt' => route.rt, 'dir' => dir}
        Direction.find_or_create_by(direction)
        directions.push(direction)
      }
      directions.push(response)
    }
    render json: directions
  end

  def stops
    directions = Direction.all
    request = request_base('stops')
    stops = Array.new
    directions.each { |direction|
      direction_request = request + request_params({
        :rt => direction.rt,
        :dir => direction.dir
        })
      response = HTTParty.get(direction_request)
      response_stops = response['bustime_response']['stop']
      if response_stops.kind_of?(Hash)
        response_stops = [response_stops]
      end
      response_stops.each { |stop|
        stop[:rt] = direction.rt
        stop[:dir] = direction.dir
        Stop.find_or_create_by(stop)
        stops.push(stop)
      }
    }
    render json: stops
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
