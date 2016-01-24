class RequestsController < ApplicationController

  def index
    @requests = Request.select("*").joins(:user).order("id DESC")
  end
  def new
    @request = Request.new
    2.times {@request.items.build}

    @category = Category.all
  end

  def create
    @request = Request.new(request_params)

    if @request.save
      redirect_to root_path
    else
      redirect_to request_path
    end


  end

  def show
    @request = Request.find(params[:id])
    @items = @request.items
  end

  private
  def request_params
    # locate current user to user_id
    params[:request][:user_id] = current_user.uuid
    # firstime request StatId = 1 "Open"
    params[:request][:StatId] = 1
    params.require(:request).permit(:user_id, :LocId, :PlaceName, :StatId, :CatId, :cost, :fees, :delivery_at, items_attributes: [ :ItemsName, :ItemDescription ])
  end

end
