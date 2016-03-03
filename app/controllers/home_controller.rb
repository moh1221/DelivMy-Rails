class HomeController < ApplicationController
  def index
    @category = Category.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @category}
      format.json { render json: @category}
    end
  end
end
