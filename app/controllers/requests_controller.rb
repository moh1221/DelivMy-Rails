class RequestsController < ApplicationController

  before_action :require_user, only: [:index, :new, :create]

  def index
    @requests = Request.select("requests.id, requests.PlaceName, requests.created_at, cost, fees, delivery_at, first_name, last_name, email, CatName, status_info").where('requests.user_id = ?', current_user)
                    .joins(:profile).joins(:status)
                    .joins(:category)
                    .order("status_info, delivery_at DESC")
  end
  def new
    @request = Request.new
    2.times {@request.items.build}
    @request.build_location
    @category = Category.all

  end

  def create
    @request = Request.new(request_params)
    @category = Category.all
    print("I'm at create")
    if @request.save
      redirect_to '/requests'
    else
      puts(@request.errors.any?)
      puts(@request.errors.count)
      puts(@request.errors.full_messages)
      2.times {@request.items.build}
      @request.build_location
      @category = Category.all
      render :action => 'new'
    end
  end

  def show
    @request = Request.find(params[:id])
    @deliver = @request.deliver
    @items = @request.items
    @location = @request.location
  end

  def destroy
    @request = Request.find(params[:id])

    respond_to do |format|
      if @request[:status_id] == 1
        @request.destroy
        format.html { redirect_to requests_path }
      else
        format.html { redirect_to request_path, notice: "Request can't be removerd Status: On Progress" }
      end
    end

  end

  private
  def request_params
    # locate current user to user_id
    params[:request][:user_id] = current_user.uuid
    # firstime request StatId = 1 "Open"
    params[:request][:status_id] = 1
    params.require(:request).permit(:user_id, :PlaceName, :status_id, :category_id, :cost, :fees, :delivery_at, items_attributes: [ :ItemsName, :ItemDescription ], location_attributes: [:address, :Lat, :Long])
  end

end
