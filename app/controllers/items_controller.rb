class ItemsController < ApplicationController
  before_action :require_user

  def index
    @request = readable_request(params[:request_id])
    @items = @request.items

    respond_to do |format|
      format.html
      format.json { render json: @items, except: [:updated_at] }
    end
  end
end
