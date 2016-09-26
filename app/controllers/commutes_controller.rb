class CommutesController < ApplicationController
  include MapApis
  include RouteScheduler

  before_action :authenticate_user!
  before_filter :setup_commute, :only => [:show, :edit, :update, :destroy, :reports, :ghosts, :track_ghosts, :fetch_ghosts]
  before_filter :require_permission, :only => [:show, :edit, :update, :destroy, :ghosts]

  def index
    render json: @commutes = current_user.commutes
  end

  def new
    @commute = Commute.new({ :user_id => current_user.id})
  end

  def create
    @commute = Commute.new(commute_params)
    @commute.save
    redirect_to @commute
  end

  def show
    render json: @commute
  end

  def edit
    render json: @commute
  end

  def update
    @commute.update_attributes(params[:commute])
    redirect_to @commute
  end

  def destroy
    @commute.destroy
    redirect_to commutes_path
  end

  def reports
    reports = Hash.new
    @commute.ghost_commutes.each do |ghost_commute|
      steps = ghost_commute.ghost_steps
      reports[ghost_commute.id] = steps.map { |step| step.duration }
    end
    render json: reports
  end

  def ghosts
    render json: @ghost_commutes = @commute.ghost_commutes
  end

  def track_ghosts
    @commute.ghost_commutes.each do |ghost_commute|
      ghost_commute.track
    end
    render json: @commute.ghost_commutes
  end

  def fetch_ghosts
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
          'origin_long' => step['start_location']['lng'],
          'dest_lat' => step['end_location']['lat'],
          'dest_long' => step['end_location']['lng']
        }
        if step['travel_mode'] == 'TRANSIT'
          step_data.merge!({
            'step_type' => details['line']['vehicle']['type'],
            'line' => details['line']['name'],
            'origin' => details['departure_stop']['name'],
            'dest' => details['arrival_stop']['name'],
            'heading' => details['headsign']
            })
        elsif step['travel_mode'] == 'WALKING'
          step_data.merge!({'duration' => step['duration']['value']})
        end
        ghost_step = GhostStep.create(step_data)
      end
    end
    render json: @commute.ghost_commutes
  end

  private

    def commute_params
      params.require(:commute).permit(:user_id,:origin,:dest,:departure_time,:origin_lat,:origin_long,:dest_lat,:dest_long)
    end

    def setup_commute
      @commute = Commute.find(params[:id])
    end

    def require_permission
      render :text => 'Unauthorized', :status => :unauthorized if @commute.user != current_user if current_user != @commute.user
    end

end
