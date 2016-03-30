class SearchController < ApplicationController
  before_action :require_user, only: [:index, :show]

  def index
    search = Request.selected_val.search_filter(current_user).search_joins.search_order

    if params[:sw]
      @search = search.in_bounds([params[:sw], params[:ne]], :origin => params[:center])
      respond_to do |format|
        format.html { render partial: 'list_field'}# index.html.erb
        format.json { render json: @search }
      end

    else
      @search = search.limit(20)
    end
  end

  def show
    @search = Request.find(params[:id])
    @items = @search.items
    @location = @search.location
  end
end
