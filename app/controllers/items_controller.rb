class ItemsController < ApplicationController
  def index
    @request = Request.find(params[:request_id])
    @items = @request.items

    respond_to do |format|
      format.html
      format.json { render json: @items, except: [:updated_at] }
    end
  end
end
