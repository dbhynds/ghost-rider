class GhostCommute < ActiveRecord::Base
  belongs_to :commute
  has_many :ghost_steps
end
