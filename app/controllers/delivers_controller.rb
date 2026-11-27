class DeliversController < ApplicationController
  before_action :require_user
  skip_forgery_protection if: -> { action_name == "create" && bearer_authenticated? }

  def index
    @delivers = Request.joins(:deliver).where(delivers: { user_id: current_user.id })
      .includes(:items, :category, profile: { avatar_attachment: :blob }, deliver: { profile: { avatar_attachment: :blob } })
      .order(id: :desc)

    respond_to do |format|
      format.html
      format.json do
        presenter = RequestPayload.new(view_context)
        render json: @delivers.map { |order| presenter.order(order, delivery: true, profile: true) }
      end
    end
  end

  def new
    redirect_to search_path
  end

  def create
    order = Request.find(params.expect(:request_id))
    order.accept_by!(current_user)

    respond_to do |format|
      format.html { redirect_to delivers_path, status: :see_other }
      format.json { render json: { message: "Success" } }
    end
  rescue Request::Unavailable, ActiveRecord::RecordNotUnique, ActiveRecord::LockWaitTimeout => error
    message = error.is_a?(Request::Unavailable) ? error.message : "This request is no longer available."
    render_conflict(message, redirect: search_path)
  end

  def show
    @request = Request.includes(:items, :location).joins(:deliver)
      .where("requests.user_id = :id OR delivers.user_id = :id", id: current_user.id).find(params[:id])
    @deliver = @request.deliver

    respond_to do |format|
      format.html
      format.json { render json: RequestPayload.new(view_context).courier(@deliver) }
    end
  end
end
