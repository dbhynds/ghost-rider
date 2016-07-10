class Busroute < ActiveRecord::Base
  belongs_to :busline
  belongs_to :busdirection
  has_and_belongs_to_many :busstops
end
