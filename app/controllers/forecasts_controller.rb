class ForecastsController < ApplicationController
  def show
  end

  def create
    address = params[:address]
    result = ForecastService.new(address).call

    if result[:error]
      @error = result[:error]
      render :show and return
    end

    @forecast = result
    render :show
  end
end
