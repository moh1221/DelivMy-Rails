class SearchController < ApplicationController
  before_action :require_user, only: [:index, :show]
  def index
    @search = Request.select("requests.id, requests.PlaceName, requests.created_at, cost, fees, delivery_at, users.first_name, users.last_name, users.email, CatName, picture")
                  .where('requests.delivery_at > ? and requests.user_id != ? and requests.StatId = 1', DateTime.now, current_user)
                  .joins(:user).joins(:profile)
                  .joins(:category).includes(:location)
                  .includes(:items)
                  .order("requests.id DESC")
  end

  def show
    @search = Request.find(params[:id])
    @items = @search.items
    @location = @search.location


  end
end
