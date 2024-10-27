# app/services/forecast_service.rb
class ForecastService
  def initialize(address)
    @address = address
  end

  def call
    geocode_result = GeocodioClient.instance.geocode([@address])

    # Handle invalid address
    return { error: 'Invalid address. Please try again.' } if geocode_result['error']

    geocode_result, zip, lat, lng = extract_location_data(geocode_result)

    # Fetch from cache or make a new API call
    forecast, from_cache = fetch_forecast(zip, lat, lng)

    # Build the forecast response
    build_forecast_response(geocode_result, forecast, from_cache)
  end

  private

  def extract_location_data(geocode_result)
    result = geocode_result['results'][0]
    zip = result['address_components']['zip']
    lat = result['location']['lat']
    lng = result['location']['lng']

    # the zip may be null if the address the user entered was very broad (ex. California),
    # so we need to reverse geocode to get the zip
    if !zip
      geocode_result = GeocodioClient.instance.reverse(["#{lat},#{lng}"], [], 1)
      zip = geocode_result['results'][0]['address_components']['zip']
    end

    [geocode_result, zip, lat, lng]
  end

  def fetch_forecast(zip, lat, lng)
    from_cache = true
    forecast = Rails.cache.fetch("#{zip}_forecast", expires_in: 30.minutes) do
      from_cache = false
      OpenWeatherClient.instance.current_weather(lat: lat, lon: lng, units: 'imperial')
    end
    [forecast, from_cache]
  end

  def build_forecast_response(geocode_result, forecast, from_cache)
    result = geocode_result['results'][0]

    {
      address: result['formatted_address'],
      temperature: forecast['main']['temp'],
      description: forecast['weather'][0]['description'],
      icon: forecast['weather'][0]['icon'],
      from_cache: from_cache
    }
  end
end
