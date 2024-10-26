require 'rails_helper'

RSpec.describe "Forecasts", type: :request do
  describe "GET /index" do
    it 'accepts an address as input' do
      post '/forecast', params: { address: 'One Apple Park Way, Cupertino, CA 95014' }
      expect(response).to have_http_status(:ok)
    end
  end
end
