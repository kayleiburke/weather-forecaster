require 'rails_helper'

RSpec.describe "Forecasts", type: :request do
  describe "GET /index" do

    describe "POST /forecast" do
      it "retrieves forecast data for a valid address" do

        # Mock the Geocodio API response
        geocode_stub = load_json_stub('geocode_stub.json')
        allow_any_instance_of(Geocodio::Gem).to receive(:geocode).and_return(geocode_stub)

        # Mock the OpenWeather API response
        weather_stub = {
          'main' => { 'temp' => 75 },
          'weather' => [{ 'description' => 'clear sky', 'icon' => '01d' }]
        }
        allow_any_instance_of(OpenWeather::Client).to receive(:current_weather).and_return(weather_stub)

        post '/forecast', params: { address: 'One Apple Park Way, Cupertino, CA' }

        expect(response).to have_http_status(:ok)

        forecast = assigns(:forecast)
        expect(forecast[:address]).to eq('1 Apple Park Way, Cupertino, CA 95014')
        expect(forecast[:temperature]).to eq(75)
        expect(forecast[:description]).to eq('clear sky')
        expect(forecast[:icon]).to eq('01d')
      end
    end

    it 'returns an error for an invalid address' do
      # Mock the Geocoding API response
      geocode_stub = { 'error' => 'Invalid address' }
      allow_any_instance_of(Geocodio::Gem).to receive(:geocode).and_return(geocode_stub)

      post '/forecast', params: { address: 'Invalid Address' }

      expect(response).to have_http_status(:ok)
      error = assigns(:error)
      expect(error).to eq('Invalid address. Please try again.')
    end

    it 'caches forecast details for 30 minutes' do
      allow(Rails.cache).to receive(:fetch).and_call_original

      post '/forecast', params: { address: 'One Apple Park Way, Cupertino, CA 95014' }
      expect(Rails.cache).to have_received(:fetch).with('95014_forecast', expires_in: 30.minutes)
    end

  end
end
