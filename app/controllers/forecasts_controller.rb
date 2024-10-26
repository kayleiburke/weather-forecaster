class ForecastsController < ApplicationController

  def show
  end
  def create
    address = params[:address]
    geocodio = Geocodio::Gem.new(ENV["GEOCODIO_API_KEY"])
    geocode_result = geocodio.geocode([address])

    if geocode_result['error']
      @error = 'Invalid address. Please try again.'
      render :show and return
    end

    lat = geocode_result['results'][0]['location']['lat']
    lng = geocode_result['results'][0]['location']['lng']

    weather = OpenWeather::Client.new(api_key: ENV["OPENWEATHER_API_KEY"])
    forecast = weather.current_weather(lat: lat, lon: lng, units: 'imperial')

    puts forecast
    @forecast = {
      address: geocode_result['results'][0]['formatted_address'],
      temperature: forecast['main']['temp'],
      description: forecast['weather'][0]['description']
    }

    render :show
  end

end
