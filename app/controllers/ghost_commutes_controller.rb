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
    tracked_steps = track_next_steps(@ghost_commute.ghost_steps.to_a.reverse!)
    puts tracked_steps
    render json: @ghost_commute.ghost_steps.to_a.reverse!
  end

end
