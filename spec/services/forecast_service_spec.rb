# spec/services/forecast_service_spec.rb
require 'rails_helper'

RSpec.describe ForecastService do
  let(:detailed_address) { 'One Apple Park Way, Cupertino, CA' }
  let(:broad_address) { 'California' }
  let(:detailed_address_geocode_stub) { load_json_stub('geocode_stub_one_apple_park_way_cupertino_ca.json') }
  let(:broad_address_geocode_stub) { load_json_stub('geocode_stub_california.json') }
  let(:reverse_geocode_stub) { load_json_stub('reverse_geocode_stub_california.json') }
  let(:invalid_address_stub) { { 'error' => 'Invalid address' } }

  let(:lat) { detailed_address_geocode_stub.dig('results', 0, 'location', 'lat') }
  let(:lng) { detailed_address_geocode_stub.dig('results', 0, 'location', 'lng') }
  let(:zip) { detailed_address_geocode_stub.dig('results', 0, 'address_components', 'zip') }

  let(:weather_stub) do
    { 'main' => { 'temp' => 75 }, 'weather' => [{ 'description' => 'clear sky', 'icon' => '01d' }] }
  end

  before do
    allow(OpenWeatherClient.instance).to receive(:current_weather).and_return(weather_stub)
    allow(Rails.cache).to receive(:fetch).and_call_original
  end

  describe '#call' do
    context 'when the address is detailed and valid' do
      it 'returns the correct forecast data' do
        allow(GeocodioClient.instance).to receive(:geocode).and_return(detailed_address_geocode_stub)

        service = described_class.new(detailed_address)
        result = service.call

        expect(result).to eq(
                            {
                              address: '1 Apple Park Way, Cupertino, CA 95014',
                              temperature: 75,
                              description: 'clear sky',
                              icon: '01d',
                              from_cache: false
                            }
                          )
      end
    end

    context 'when an invalid address is provided' do
      before do
        allow(GeocodioClient.instance).to receive(:geocode).and_return({ 'error' => 'Invalid address' })
      end

      it 'returns an error message' do
        service = described_class.new('Invalid Address')
        result = service.call

        expect(result).to eq({ error: 'Invalid address. Please try again.' })
      end
    end

    context 'when the address is too broad for geocode to return a zip code' do
      before do
        allow(GeocodioClient.instance).to receive(:geocode).and_return(broad_address_geocode_stub)
        allow(GeocodioClient.instance).to receive(:reverse).and_return(reverse_geocode_stub)
      end

      it 'attempts reverse geocoding to fetch the zip code' do
        service = described_class.new(broad_address)
        service.call

        lat = broad_address_geocode_stub.dig('results', 0, 'location', 'lat')
        lng = broad_address_geocode_stub.dig('results', 0, 'location', 'lng')

        expect(GeocodioClient.instance).to have_received(:reverse).with(["#{lat},#{lng}"], [], 1)
      end
    end

    context 'when the reverse geocoding fails to find a zip code' do
      before do
        allow(GeocodioClient.instance).to receive(:geocode).and_return(broad_address_geocode_stub)
        allow(GeocodioClient.instance).to receive(:reverse).and_return({})
      end

      it 'returns a location error message' do
        service = described_class.new(broad_address)
        result = service.call

        expect(result).to eq({ error: 'Could not determine the location. Please provide a more specific address.' })
      end
    end

    context 'when an exception is raised' do
      before do
        allow(GeocodioClient.instance).to receive(:geocode).and_raise(StandardError, 'Test error')
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error and returns a generic error message' do
        service = described_class.new(detailed_address)
        result = service.call

        expect(result).to eq({ error: 'An error occurred. Please try again later.' })
        expect(Rails.logger).to have_received(:error).with(instance_of(StandardError))
      end
    end
  end

  describe '#extract_location_data' do
    it 'returns geocode data, zip, lat, and lng' do
      service = described_class.new(detailed_address)
      result = service.send(:extract_location_data, detailed_address_geocode_stub)

      expect(result).to eq([detailed_address_geocode_stub, zip, lat, lng])
    end
  end

  describe '#fetch_forecast' do
    it 'fetches the forecast and returns it from cache' do
      service = described_class.new(detailed_address)

      forecast, from_cache = service.send(:fetch_forecast, zip, lat, lng)

      expect(forecast).to eq(weather_stub)
      expect(from_cache).to be(false)
    end
  end

  describe '#build_forecast_response' do
    it 'builds the forecast response' do
      service = described_class.new(detailed_address)
      response = service.send(:build_forecast_response, detailed_address_geocode_stub, weather_stub, true)

      expect(response).to eq(
                            {
                              address: '1 Apple Park Way, Cupertino, CA 95014',
                              temperature: 75,
                              description: 'clear sky',
                              icon: '01d',
                              from_cache: true
                            }
                          )
    end
  end
end
