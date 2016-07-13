class GhostCommutesController < ApplicationController
  include RouteScheduler

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

end
