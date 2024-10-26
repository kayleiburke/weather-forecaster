class ForecastsController < ApplicationController

  def show
    address = params[:address]
    render json: { message: "Received address: #{address}" }
  end

end
