class SessionsController < ApplicationController

  after_filter :set_csrf_header, only: [:new, :create]

  def new
  end

  def create
    @user = User.find_by_email(params[:session][:email])
    if @user && @user.authenticate(params[:session][:password])
      # session[:user_id] = @user.id

      if params[:remember_me]
        cookies.permanent[:auth_token] = @user.auth_token
      else
        cookies[:auth_token] = @user.auth_token
      end
      respond_to do |format|
        format.html { redirect_to '/search'}# index.html.erb
        format.json { render status: :ok, json: {session: { id: @user.auth_token, user_id: @user.id }} }
      end
    else
      flash.now.alert = "Invalid email or password"
      respond_to do |format|
        format.html { redirect_to '/login'}# index.html.erb
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # session[:user_id] = nil
    print("Printing cookiessss-------- #{cookies}")

    cookies.delete(:auth_token)
    respond_to do |format|
      format.html { redirect_to '/'}# index.html.erb
      format.json { render status: :ok }
    end

  end

  protected

  def set_csrf_header
    response.headers['XSRF-TOKEN'] = form_authenticity_token
  end

end
