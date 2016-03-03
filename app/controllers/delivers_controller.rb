class DeliversController < ApplicationController

  before_action :require_user, only: [:index, :new, :create]

  def index
    @delivers = Request.select("*").where('requests.user_id = ?', current_user).joins(:deliver).joins(:user).order("requests.id DESC")

  end

  def new
    @deliver = Deliver.new
  end

  def create
    @deliver = Deliver.new(deliver_params)

    if @deliver.save
      if @deliver.request.update(StatId: 2)
        redirect_to '/delivers'
      else
        redirect_to deliver_path
      end
    else
      redirect_to deliver_path
    end
  end



  def show
    @deliver = Deliver.find(params[:id])
    @items = @deliver.items
    @location = @deliver.location
  end

  private
  def deliver_params
    # locate current user to user_id
    print(current_user.uuid)
    params[:deliv_Status] = 1
    params[:user_id] = current_user.uuid
    # firstime request StatId = 1 "Open"

    params[:receipt_img] = ""
    params[:completed_at] = ""

    params.permit(:request_id, :user_id, :deliv_Status, :receipt_img, :completed_at)
  end

  # private
  # def deliver_params
  #   params.require(:deliver).permit(:request_id)
  # end

end
