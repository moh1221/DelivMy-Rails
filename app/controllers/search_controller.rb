class SearchController < ApplicationController
  before_action :require_user, only: [:index, :show]

  def index
    search = Request.selected_val.search_filter(current_user).search_joins.search_order
    searchMy = Request.search_filter(current_user).search_includes
    if params[:sw]
      @mySearch = searchMy.in_bounds([params[:sw], params[:ne]], :origin => params[:center])
      @search = search.in_bounds([params[:sw], params[:ne]], :origin => params[:center])
      respond_to do |format|
        format.html { render partial: 'list_field'}# index.html.erb
        format.json { render json: @mySearch, include: [ { profile: {only: [:first_name, :last_name, :picture]}}, { location: { except: [:updated_at, :created_at]}} , {items: {only: :id}}, {category: {only: :CatName}}] }
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
