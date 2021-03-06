require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CommuteOptimizer
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.bus_api_key = 'GwbCAKaDHXbqwXpB9jNrqmXhN'
    config.bus_api_uri = 'http://www.ctabustracker.com/bustime/api/v1/'
    config.train_api_key = '22eaaf6659e84c3e870afc0936efee71'
    config.train_api_uri = 'http://lapi.transitchicago.com/api/1.0/'
    config.gmaps_api_key = 'AIzaSyB7IISLr7_ejDrcVm-n-Cht7aTC9KhW-yc'
    config.gmaps_api_uri = 'https://maps.googleapis.com/maps/api/directions/json'
    config.autoload_paths << Rails.root.join('lib')
  end
end
