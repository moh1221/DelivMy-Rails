class LocationsController < ApplicationController

  def index
    @request = Request.find(params[:request_id])
    @location = @request.location

    respond_to do |format|
      format.json { render json: @location, except: [:updated_at] }
    end

  end
end
