class Commute < ActiveRecord::Base
  belongs_to :user
  has_many :ghost_commutes, dependent: :destroy
  validates :user, presence: true

end
