class Commute < ActiveRecord::Base
  include MapApis

  belongs_to :user
  has_many :ghost_commutes, dependent: :destroy
  validates :user, presence: true

  def fetchGhosts
    request = gmaps_request({
      'origin' => origin_lat.to_s + ',' + origin_long.to_s,
      'destination' => dest_lat.to_s + ',' + dest_long.to_s,
      'mode' => 'transit',
      'alternatives' => 'true'
      })
    routes = HTTParty.get(request).parsed_response['routes']
    routes.each do |route|
      ghost_commute = ghost_commutes.create
      route['legs'].shift['steps'].each do |step|
        details = step['transit_details']
        step_data = {
          'mode' => step['travel_mode'],
          'origin_lat' => step['start_location']['lat'],
          'origin_long' => step['start_location']['lng'],
          'dest_lat' => step['end_location']['lat'],
          'dest_long' => step['end_location']['lng']
        }
        if step['travel_mode'] == 'TRANSIT'
          step_data.merge!({
            'step_type' => details['line']['vehicle']['type'],
            'line' => details['line']['name'],
            'origin' => details['departure_stop']['name'],
            'dest' => details['arrival_stop']['name'],
            'heading' => details['headsign']
            })
        elsif step['travel_mode'] == 'WALKING'
          step_data.merge!({'duration' => step['duration']['value']})
        end
        ghost_step = ghost_commute.ghost_steps.create step_data
      end
    end
    ghost_commutes
  end

end
