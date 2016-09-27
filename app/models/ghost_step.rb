class GhostStep < ActiveRecord::Base
  belongs_to :ghost_commute
  has_many :active_steps, dependent: :destroy
  validates :ghost_commute, presence: true

  def track
    active_steps.create(:start_time => Time.now.to_i)
  end
end
