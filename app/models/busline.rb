class Busline < ActiveRecord::Base
  has_many :busroutes
  has_many :busdirections, through: :busroutes
end
