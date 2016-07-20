class GhostCommute < ActiveRecord::Base
  include RouteScheduler

  belongs_to :commute
  has_many :ghost_steps

  def track
    puts self
    track_next_steps(self.ghost_steps.to_a.reverse!)
  end

end
