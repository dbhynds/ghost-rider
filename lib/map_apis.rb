module MapApis

  def bus_request(resource, param_array = {})
    bus_base(resource) + request_params(param_array)
  end

  def train_request(resource, param_array = {})
    train_base(resource) + request_params(param_array)
  end

  def gmaps_request(param_array)
    base = append_key('https://maps.googleapis.com/maps/api/directions/json',CommuteOptimizer::Application.config.gmaps_api_key)
    base + request_params(param_array)
  end



  private

    def append_key(url, key)
      url + '?key=' + key
    end

    def bus_base(resource)
      append_key(
        CommuteOptimizer::Application.config.bus_api_uri + 'get' + resource,
        CommuteOptimizer::Application.config.bus_api_key
      )
    end

    def train_base(resource)
      append_key(
        CommuteOptimizer::Application.config.train_api_uri + 'tt' + resource + '.aspx',
        CommuteOptimizer::Application.config.train_api_key
      )
    end

    def request_params(param_array)
      param_strings = String.new
      param_array.each { |key,val|
        param_string = "\&#{URI.escape(key)}=#{URI.escape(val.to_s)}"
        param_strings << param_string
      }
      param_strings
    end

end
