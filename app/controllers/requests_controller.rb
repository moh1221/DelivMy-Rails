class RequestsController < ApplicationController

  def index
    @requests = Request.select("*").joins(:user).order("id DESC")
    puts(@requests)
  end
  def new
    @request = Request.new
    2.times {@request.items.build}
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
    params[:request][:user_id] = current_user.uuid
    params.require(:request).permit(:user_id, :LocId, :PlaceName, :StatId, :CatId, items_attributes: [ :ItemsName, :ItemDescription, :_destroy ])
  end

end
