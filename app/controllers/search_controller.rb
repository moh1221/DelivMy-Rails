class SearchController < ApplicationController
  def index
    @search = Request.select("requests.id, requests.PlaceName, requests.created_at, cost, fees, delivery_at, first_name, last_name, email, CatName").where('requests.delivery_at > ? and requests.user_id != ? and requests.StatId = 1', DateTime.now, current_user).joins(:user).joins(:category).order("requests.id DESC")
  end

  def show
    @search = Request.find(params[:id])
    @items = @search.items
    @location = @search.location
  end
end
