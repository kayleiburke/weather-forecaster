# app/services/openweather_client.rb
class OpenWeatherClient
  include Singleton

  def initialize
    @client = OPENWEATHER_CLIENT
  end

  def current_weather(lat:, lon:, units: "imperial")
    @client.current_weather(lat: lat, lon: lon, units: units)
  end
end
