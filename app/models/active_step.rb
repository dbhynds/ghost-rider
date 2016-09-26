class ActiveStep < ActiveRecord::Base
  belongs_to :ghost_step
  validates :ghost_step, presence: true
  attr_reader :mode

  def mode
    return self.ghost_step.step_type unless ghost_step.mode == 'WALKING'
    self.ghost_step.mode
  end
end
