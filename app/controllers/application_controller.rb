class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery

  helper_method :current_user

  def current_user
    @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  end

  def require_user
    redirect_to '/login' unless current_user
  end

  def require_author
    redirect_to '/' unless current_user.author?
  end
end
