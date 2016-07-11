class CommutesController < ApplicationController

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

  private

    def commute_params
      params.require(:commute).permit(:user_id, :origin, :dest, :departure_time, :origin_lat, :origin_long, :dest_lat, :dest_long)
    end

end
