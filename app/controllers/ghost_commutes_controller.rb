class GhostCommutesController < ApplicationController
  include RouteScheduler

  def index
    render json: GhostCommute.all
  end

  def show
    render json: GhostCommute.find(params[:id])
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

end
