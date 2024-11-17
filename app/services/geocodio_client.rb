# app/services/geocodio_client.rb
class GeocodioClient
  include Singleton

  def initialize
    @client = GEOCODIO_CLIENT
  end

  def geocode(address)
    @client.geocode(address)
  end

  def reverse(coords, extra = [], limit = 1)
    @client.reverse(coords, extra, limit)
  end
end
