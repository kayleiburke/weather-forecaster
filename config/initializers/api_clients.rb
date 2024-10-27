# config/initializers/api_clients.rb

GEOCODIO_CLIENT = Geocodio::Gem.new(ENV["GEOCODIO_API_KEY"])
OPENWEATHER_CLIENT = OpenWeather::Client.new(api_key: ENV["OPENWEATHER_API_KEY"])
