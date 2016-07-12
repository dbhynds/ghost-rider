class CommutesController < ApplicationController
  include MapApis

  before_action :authenticate_user!

  def index
    render json: Commute.all
  end

  def new
    @commute = Commute.new
    @commute.user_id = current_user.id
  end

  def create
    @commute = Commute.new(commute_params)
    @commute.save
    render json: @commute
  end

  def show
    @commute = Commute.find(params[:id])
    render json: @commute
  end

  def track
    @commute = Commute.find(params[:id])
    #https://maps.googleapis.com/maps/api/directions/json?origin=41.954288131006,-87.675206065178&destination=41.780420933475,-87.606294751167&mode=transit&alternatives=true&key=AIzaSyB7IISLr7_ejDrcVm-n-Cht7aTC9KhW-yc
    request = gmaps_request({
      'origin' => @commute.origin_lat.to_s + ',' + @commute.origin_long.to_s,
      'destination' => @commute.dest_lat.to_s + ',' + @commute.dest_long.to_s,
      'mode' => 'transit',
      'alternatives' => 'true'
      })
    routes = HTTParty.get(request).parsed_response['routes']
    routes.each do |route|
      ghost_commute = GhostCommute.create({'commute' => @commute})
      route['legs'].shift['steps'].each do |step|
        details = step['transit_details']
        step_data = {
          'ghost_commute' => ghost_commute,
          'mode' => step['travel_mode'],
          'origin_lat' => step['start_location']['lat'],
          'origin_long' => step['end_location']['lng']
        }
        if step['travel_mode'] == 'TRANSIT'
          # step_data['type'] = details['line']['vehicle']['type']
          step_data['line'] = details['line']['name']
          step_data['origin'] = details['arrival_stop']['name']
        end

        # Rails.logger.info(step)
        ghost_step = GhostStep.create(step_data)
      end
    end
    render json: routes
  end

  private

    def commute_params
      params.require(:commute).permit(:user_id, :origin, :dest, :departure_time, :origin_lat, :origin_long, :dest_lat, :dest_long)
    end

end
