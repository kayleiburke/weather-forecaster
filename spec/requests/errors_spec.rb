require 'rails_helper'

RSpec.describe "Errors", type: :request do
  describe "GET /not_found" do
    it "returns a 404 not found response" do
      get "/non-existent-route"

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("404 - Page Not Found")
    end
  end
end
