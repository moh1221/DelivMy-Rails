class SearchController < ApplicationController
  before_action :require_user, only: [:index, :show]
  def index
    valData = [:id, :PlaceName, :created_at, :cost, :fees, :delivery_at, :first_name, :last_name, :email, :CatName, :picture, :Lat, :Long, :address]
    if params[:sw].present?
      returnVal = [:id, :request_id, :PlaceName, :created_at, :cost, :fees, :delivery_at, :Lat, :Long, :address]
      # @search = Location.select("*").in_bounds([params[:sw], params[:ne]], :origin => params[:center]).joins(:request)
      @search = Request.select(valData)
                    .where('requests.delivery_at > ? and requests.user_id != ?', DateTime.now, current_user)
                    .joins(:profile)
                    .joins(:category).joins(:location).in_bounds([params[:sw], params[:ne]], :origin => params[:center])
                    .includes(:items)
                    .order("requests.id DESC")
      respond_to do |format|
        # format.html { render partial: 'list_field'}# index.html.erb
        format.json { render json: @search }
        format.js
      end
    else
      @search = Request.select(valData)
                    .where('requests.delivery_at > ? and requests.user_id != ? and requests.StatId = 1', DateTime.now, current_user)
                    .joins(:profile)
                    .joins(:category).joins(:location)
                    .includes(:items)
                    .order("requests.id DESC")

    end
  end

  def show
    @search = Request.find(params[:id])
    @items = @search.items
    @location = @search.location
  end
end
