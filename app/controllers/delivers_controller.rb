class DeliversController < ApplicationController

  before_action :require_user, only: [:index, :new, :create]

  def index
    @delivers = Request.request_deliver_select.current_delivery(current_user).recent_deliver
    @request = Request.joins(:deliver).where('delivers.user_id = ?', current_user ).includes(:items, :category, :profile)

    respond_to do |format|
      format.html
      format.json { render json: @request, include: [:deliver,{ profile: {only: [:first_name, :last_name, :picture]}} , {items: {only: :id}}, {category: {only: :CatName}}] }
    end
  end

  def new
    @deliver = Deliver.new
  end

  def create
    @deliver = Deliver.new(deliver_params)

    if @deliver.save
      respond_to do |format|
        if @deliver.request.update(status_id: 2)
          format.html { redirect_to '/delivers' }
          format.json { render status => :ok, json: { message: "Success" }  }
        else
          format.html { redirect_to deliver_path}
          format.json { render :json => @deliver.errors, :status => :unprocessable_entity }
        end
      end
    else
      redirect_to deliver_path
    end
  end

  def show
    @request = Request.includes(:items, :location, :profile, :deliver).find(params[:id])

    @requests = Request.find(params[:id])
    @deliver = @requests.deliver

    respond_to do |format|
      format.html
      format.json { render json: @deliver, include: [:profile] }
    end
  end

  private
  def deliver_params
    params[:user_id] = current_user.uuid
    params.permit(:request_id, :user_id, :deliv_Status, :receipt_img, :completed_at)
  end
end
