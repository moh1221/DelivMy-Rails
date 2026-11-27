class LocationsController < ApplicationController
  before_action :require_user

  def index
    order = readable_request(params[:request_id])
    data = order.participant?(current_user) ? order.location&.as_json(except: [:updated_at]) : order.location&.listing_payload
    render json: data
  end
end
