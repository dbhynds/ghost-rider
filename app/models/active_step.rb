class ActiveStep < ActiveRecord::Base
  belongs_to :ghost_step
  validates :ghost_step, presence: true
  attr_reader :mode, :origin, :destination, :origin_lat, :origin_long, :dest_lat, 
    :dest_long, :duration, :heading

  def mode
    return ghost_step.step_type unless ghost_step.mode == 'WALKING'
    ghost_step.mode
  end

  def origin
    ghost_step.origin
  end

  def destination
    ghost_step.dest
  end

  def origin_lat
    ghost_step.origin_lat
  end

  def origin_long
    ghost_step.origin_long
  end

  def dest_lat
    ghost_step.dest_lat
  end

  def dest_long
    ghost_step.dest_long
  end

  def duration
    ghost_step.duration
  end

  def heading
    ghost_step.heading
  end

end
