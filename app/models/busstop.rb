class Busstop < ActiveRecord::Base
  has_and_belongs_to_many :busroutes
end
