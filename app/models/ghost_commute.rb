class GhostCommute < ActiveRecord::Base
  include RouteScheduler

  belongs_to :commute
  has_many :ghost_steps, dependent: :destroy
  validates :commute, presence: true

  def track
    track_next_steps(self.ghost_steps.to_a.reverse!)
  end

end
