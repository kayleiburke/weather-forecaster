class ForecastsController < ApplicationController

  def show
    address = params[:address] || "One Apple Park Way, Cupertino, CA 95014"
    geocodio = Geocodio::Gem.new(ENV["GEOCODIO_API_KEY"])
    geocode_result = geocodio.geocode([address])

    if geocode_result['error']
      render json: { error: 'Invalid address' }, status: :unprocessable_entity
      return
    end

    lat = geocode_result['results'][0]['location']['lat']
    lng = geocode_result['results'][0]['location']['lng']

    weather = OpenWeather::Client.new(api_key: ENV["OPENWEATHER_API_KEY"])
    forecast = weather.current_weather(lat: lat, lon: lng, units: 'imperial')

    render json: { address: address, temperature: forecast['main']['temp'], description: forecast['weather'][0]['description'] }
  end

end
