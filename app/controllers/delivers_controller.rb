class DeliversController < ApplicationController

  before_action :require_user, only: [:index, :new, :create]

  def index
    @delivers = Request.request_deliver_select.current_delivery(current_user).recent_deliver
  end

  def new
    @deliver = Deliver.new
  end

  def create
    @deliver = Deliver.new(deliver_params)

    if @deliver.save
      if @deliver.request.update(status_id: 2)
        redirect_to '/delivers'
      else
        redirect_to deliver_path
      end
    else
      redirect_to deliver_path
    end
  end

  def show
    @request = Request.includes(:items, :location, :profile, :deliver).find(params[:id])
  end

  private
  def deliver_params
    params[:user_id] = current_user.uuid
    params.permit(:request_id, :user_id, :deliv_Status, :receipt_img, :completed_at)
  end
end
