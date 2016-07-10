class Busdirection < ActiveRecord::Base
  has_many :busroutes
  has_many :buslines, through: :busroutes
  validates_uniqueness_of :dir
end
