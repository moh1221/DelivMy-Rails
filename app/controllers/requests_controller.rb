class RequestsController < ApplicationController

  before_action :require_user, only: [:index, :new, :create]

  def index
    @requests = Request.select("requests.id, requests.PlaceName, requests.created_at, cost, fees, delivery_at, first_name, last_name, email, CatName").where('requests.user_id = ?', current_user)
                    .joins(:user)
                    .joins(:category)
                    .order("requests.id DESC")
  end
  def new
    @request = Request.new
    2.times {@request.items.build}
    @request.build_location

    @category = Category.all

  end

  def create
    @request = Request.new(request_params)
    print("I'm at create")
    if @request.save
      redirect_to '/requests'
    else
      redirect_to request_path
    end
  end

  def show
    @request = Request.find(params[:id])
    @items = @request.items
    @location = @request.location
  end

  private
  def request_params
    # locate current user to user_id
    params[:request][:user_id] = current_user.uuid
    # firstime request StatId = 1 "Open"
    params[:request][:StatId] = 1
    params.require(:request).permit(:user_id, :PlaceName, :StatId, :category_id, :cost, :fees, :delivery_at, items_attributes: [ :ItemsName, :ItemDescription ], location_attributes: [:address, :Lat, :Long])
  end

end
