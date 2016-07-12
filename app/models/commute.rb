class Commute < ActiveRecord::Base
  belongs_to :user
  has_many :ghost_commutes
end
