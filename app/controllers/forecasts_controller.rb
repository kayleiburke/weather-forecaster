class ForecastsController < ApplicationController

  def show
  end

  def create
    address = params[:address]
    geocode_result = GeocodioClient.instance.geocode([address])

    if geocode_result['error']
      @error = 'Invalid address. Please try again.'
      render :show and return
    end

    zip = geocode_result['results'][0]['address_components']['zip']
    lat = geocode_result['results'][0]['location']['lat']
    lng = geocode_result['results'][0]['location']['lng']

    if !zip
      geocode_result = GeocodioClient.instance.reverse(["#{lat},#{lng}"], [], 1)
      zip = geocode_result['results'][0]['address_components']['zip']
    end

    from_cache = true
    forecast = Rails.cache.fetch("#{zip}_forecast", expires_in: 30.minutes) do
      from_cache = false
      OpenWeatherClient.instance.current_weather(lat: lat, lon: lng, units: 'imperial')
    end

    @forecast = {
      address: geocode_result['results'][0]['formatted_address'],
      temperature: forecast['main']['temp'],
      description: forecast['weather'][0]['description'],
      icon: forecast['weather'][0]['icon'],
      from_cache: from_cache
    }

    render :show
  end

end
