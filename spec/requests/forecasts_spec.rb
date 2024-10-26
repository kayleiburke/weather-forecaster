require 'rails_helper'

RSpec.describe "Forecasts", type: :request do
  describe "GET /index" do

    it 'retrieves forecast data for a valid address' do
      # Mock the Geocoding API response
      geocode_stub = { 'results' => [{ 'location' => { 'lat' => 41.039466, 'lng' => -96.386993 } }] }
      allow_any_instance_of(Geocodio::Gem).to receive(:geocode).and_return(geocode_stub)

      # Mock the OpenWeather API response
      weather_stub = { 'main' => { 'temp' => 75 }, 'weather' => [{ 'description' => 'clear sky' }] }
      allow_any_instance_of(OpenWeather::Client).to receive(:current_weather).and_return(weather_stub)

      post '/forecast', params: { address: 'One Apple Park Way, Cupertino, CA 95014' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['temperature']).to eq(75)
      expect(JSON.parse(response.body)['description']).to eq('clear sky')
    end

    it 'returns an error for an invalid address' do
      # Mock the Geocoding API response
      geocode_stub = { 'error' => 'Invalid address' }
      allow_any_instance_of(Geocodio::Gem).to receive(:geocode).and_return(geocode_stub)

      post '/forecast', params: { address: 'Invalid Address' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq('Invalid address')
    end

  end
end
