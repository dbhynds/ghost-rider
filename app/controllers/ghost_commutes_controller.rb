class GhostCommutesController < ApplicationController
  include RouteScheduler

  before_action :authenticate_user!

  def index
    render json: @ghost_commutes = GhostCommute.all
  end

  def show
    render json: GhostCommute.find(params[:id])
  end

  def destroy
    @ghost_commute = GhostCommute.find(params[:id])
    @ghost_commute.destroy
    redirect_to ghost_commutes_path
  end

  def track
    Thread.new do
      begin
        ghost_commute = GhostCommute.find(params[:id])
        @ghost_steps = ghost_commute.ghost_steps.to_a.reverse!
      ensure
        ActiveRecord::Base.connection_pool.release_connection
      end
    end
    tracked_steps = track_next_steps(@ghost_steps)
    puts tracked_steps
    render json: @ghost_steps
  end

  private

    def commute_params
      params.require(:ghost_commute).permit(:commute_id,:duration)
    end

    def setup_commute
      @ghost_commute = GhostCommute.find(params[:id])
    end

    def require_permission
      render :text => 'Unauthorized', :status => :unauthorized if @ghost_commute.user != current_user
    end

end
