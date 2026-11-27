class RequestsController < ApplicationController
  before_action :require_user
  skip_forgery_protection if: -> { %w[create destroy].include?(action_name) && bearer_authenticated? }

  def index
    @requests = current_user.requests.includes(:category, :status, :profile, :items, deliver: { profile: { avatar_attachment: :blob } }).order(delivery_at: :desc)
    respond_to do |format|
      format.html
      format.json do
        presenter = RequestPayload.new(view_context)
        render json: @requests.map { |order| presenter.order(order, delivery: true) }
      end
    end
  end

  def new
    @request = current_user.requests.build
    prepare_form
  end

  def create
    @request = current_user.requests.build(request_params)
    @request.status_id = Status::OPEN

    if @request.save
      respond_to do |format|
        format.html { redirect_to requests_path, status: :see_other }
        format.json do
          render json: RequestPayload.new(view_context).order(@request, location: true, exact_location: true),
                 status: :created, location: request_path(@request, format: :json)
        end
      end
    else
      respond_to do |format|
        format.html { prepare_form; render :new, status: :unprocessable_content }
        format.json { render json: { errors: @request.errors.to_hash }, status: :unprocessable_content }
      end
    end
  end

  def show
    @request = readable_request(params[:id])
    @deliver = @request.deliver
    @items = @request.items
    @location = @request.location
    respond_to do |format|
      format.html
      format.json do
        participant = @request.participant?(current_user)
        render json: RequestPayload.new(view_context).order(@request, delivery: participant, location: true, exact_location: participant)
      end
    end
  end

  def destroy
    @request = current_user.requests.find(params[:id])
    @request.cancel!

    respond_to do |format|
      format.html { redirect_to requests_path, status: :see_other }
      format.json { head :no_content }
    end
  rescue Request::Unavailable => error
    render_conflict(error.message, redirect: request_path(@request))
  end

  private

  def prepare_form
    @request.items.build if @request.items.empty?
    @request.build_location unless @request.location
    @category = Category.order(:CatName)
  end

  def request_params
    root = params.require(:request)
    raise ActionController::ParameterMissing, :request unless root.is_a?(ActionController::Parameters)

    root.permit(:PlaceName, :category_id, :cost, :fees, :delivery_at,
      :"delivery_at(1i)", :"delivery_at(2i)", :"delivery_at(3i)", :"delivery_at(4i)", :"delivery_at(5i)",
      items_attributes: [:ItemsName, :ItemDescription, :_destroy],
      location_attributes: [:address, :Lat, :Long])
  end
end
