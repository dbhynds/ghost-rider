class GhostStep < ActiveRecord::Base
  belongs_to :ghost_commute
  validates :ghost_commute, presence: true
  has_one :active_step, dependent: :destroy
  scope :incomplete, -> { where(:completed => false) }

  def track
    active_step = build_active_step(:start_time => Time.now.to_i)
    active_step.save
    # puts active_step.attributes
    active_step
  end
end
