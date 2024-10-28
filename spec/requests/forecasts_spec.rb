require 'rails_helper'

RSpec.describe "Forecasts", type: :request do
  describe "POST /forecast" do

    let(:detailed_address_geocode_stub) do
      load_json_stub('geocode_stub_one_apple_park_way_cupertino_ca.json')
    end

    let(:broad_address_geocode_stub) do
      load_json_stub('geocode_stub_california.json')
    end

    let(:broad_address_reverse_geocode_stub) do
      load_json_stub('reverse_geocode_stub_california.json')
    end

    let(:weather_stub) do
      {
        'main' => { 'temp' => 75 },
        'weather' => [{ 'description' => 'clear sky', 'icon' => '01d' }]
      }
    end

    before do
      allow(OpenWeatherClient.instance).to receive(:current_weather).and_return(weather_stub)
    end
    
    context "when the address is a detailed valid address" do
      
      it "retrieves forecast data" do
        allow(GeocodioClient.instance).to receive(:geocode).and_return(detailed_address_geocode_stub)

        post '/forecast', params: { address: 'One Apple Park Way, Cupertino, CA' }

        expect(response).to have_http_status(:ok)

        forecast = assigns(:forecast)
        expect(forecast[:address]).to eq('1 Apple Park Way, Cupertino, CA 95014')
        expect(forecast[:temperature]).to eq(75)
        expect(forecast[:description]).to eq('clear sky')
        expect(forecast[:icon]).to eq('01d')
      end

      it "caches forecast details for 30 minutes" do
        # Enable caching and mock the cache behavior
        allow(Rails.cache).to receive(:fetch).and_call_original

        post '/forecast', params: { address: 'One Apple Park Way, Cupertino, CA 95014' }

        expect(Rails.cache).to have_received(:fetch).with('95014_forecast', expires_in: 30.minutes)
      end
      
    end
    
    context "when the address is a broad valid address" do

      before do
        allow(GeocodioClient.instance).to receive(:geocode).and_return(broad_address_geocode_stub)
        allow(GeocodioClient.instance).to receive(:reverse).and_return(broad_address_reverse_geocode_stub)
      end
      
      it "retrieves forecast data" do

        post '/forecast', params: { address: 'California' }

        expect(response).to have_http_status(:ok)

        forecast = assigns(:forecast)
        expect(forecast[:address]).to eq('27865 Tunoi Pl, North Fork, CA 93643')
        expect(forecast[:temperature]).to eq(75)
        expect(forecast[:description]).to eq('clear sky')
        expect(forecast[:icon]).to eq('01d')
      end

      it "caches forecast details for 30 minutes" do
        # Enable caching and mock the cache behavior
        allow(Rails.cache).to receive(:fetch).and_call_original

        post '/forecast', params: { address: 'California' }

        expect(Rails.cache).to have_received(:fetch).with('93643_forecast', expires_in: 30.minutes)
      end
      
    end

    it "returns an error for an invalid address" do
      allow(GeocodioClient.instance).to receive(:geocode).and_return({ 'error' => 'Invalid address' })

      post '/forecast', params: { address: 'Invalid Address' }

      expect(response).to have_http_status(:ok)

      error = assigns(:error)
      expect(error).to eq('Invalid address. Please try again.')
    end

  end
end
