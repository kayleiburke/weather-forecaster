require 'rails_helper'

RSpec.describe "Forecasts", type: :request do
  let(:detailed_address_stub) { load_json_stub('geocode_stub_one_apple_park_way_cupertino_ca.json') }
  let(:broad_address_stub) { load_json_stub('geocode_stub_california.json') }
  let(:reverse_geocode_stub) { load_json_stub('reverse_geocode_stub_california.json') }
  let(:weather_stub) do
    { 'main' => { 'temp' => 75 }, 'weather' => [{ 'description' => 'clear sky', 'icon' => '01d' }] }
  end

  before do
    allow(OpenWeatherClient.instance).to receive(:current_weather).and_return(weather_stub)
    allow(Rails.cache).to receive(:fetch).and_call_original
  end

  shared_examples "a successful forecast request" do |address, expected_address, cache_key|
    it "retrieves forecast data" do
      post '/forecast', params: { address: address }

      expect(response).to have_http_status(:ok)

      forecast = assigns(:forecast)
      expect(forecast[:address]).to eq(expected_address)
      expect(forecast[:temperature]).to eq(75)
      expect(forecast[:description]).to eq('clear sky')
      expect(forecast[:icon]).to eq('01d')
    end

    it "caches forecast details for 30 minutes" do
      post '/forecast', params: { address: address }
      expect(Rails.cache).to have_received(:fetch).with("#{cache_key}_forecast", expires_in: 30.minutes)
    end
  end

  describe "POST /forecast" do
    context "with a detailed valid address" do
      before { allow(GeocodioClient.instance).to receive(:geocode).and_return(detailed_address_stub) }

      it_behaves_like "a successful forecast request",
                      'One Apple Park Way, Cupertino, CA',
                      '1 Apple Park Way, Cupertino, CA 95014',
                      '95014'
    end

    context "with a broad valid address" do
      before do
        allow(GeocodioClient.instance).to receive(:geocode).and_return(broad_address_stub)
        allow(GeocodioClient.instance).to receive(:reverse).and_return(reverse_geocode_stub)
      end

      it_behaves_like "a successful forecast request",
                      'California',
                      '27865 Tunoi Pl, North Fork, CA 93643',
                      '93643'
    end

    context "with an invalid address" do
      before { allow(GeocodioClient.instance).to receive(:geocode).and_return({ 'error' => 'Invalid address' }) }

      it "returns an error" do
        post '/forecast', params: { address: 'Invalid Address' }

        expect(response).to have_http_status(:ok)
        expect(assigns(:error)).to eq('Invalid address. Please try again.')
      end
    end
  end
end
