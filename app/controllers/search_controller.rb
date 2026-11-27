class SearchController < ApplicationController
  before_action :require_user

  def index
    @search = Request.for_search(current_user).includes(profile: { avatar_attachment: :blob })
    if params.key?(:sw) || params.key?(:ne)
      south, west = coordinates(:sw)
      north, east = coordinates(:ne)
      raise ActionController::ParameterMissing, :sw unless south <= north

      @search = @search.in_bounds(south, west, north, east)
    end
    @search = @search.limit(100)

    respond_to do |format|
      format.html { params[:partial] == "1" ? render(partial: "list_field") : render(:index) }
      format.json do
        presenter = RequestPayload.new(view_context)
        render json: @search.map { |order| presenter.order(order, profile: true, location: true) }
      end
    end
  end

  def show
    @search = Request.for_search(current_user).find(params[:id])
    @items = @search.items
    @location = @search.location
    respond_to do |format|
      format.html
      format.json { render json: RequestPayload.new(view_context).order(@search, profile: true, location: true) }
    end
  end

  private

  def coordinates(key)
    lat, lon, extra = params.require(key).to_s.split(",", -1)
    latitude = Float(lat, exception: false)
    longitude = Float(lon, exception: false)
    return [latitude, longitude] if extra.nil? && latitude&.between?(-90, 90) && longitude&.between?(-180, 180)

    raise ActionController::ParameterMissing, key
  end
end
