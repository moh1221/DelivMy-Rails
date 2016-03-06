class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery

  force_ssl if: :ssl_configured?

  def ssl_configured?
    !Rails.env.development?
  end

  
  helper_method :current_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def require_user
    redirect_to '/login' unless current_user
  end

  def require_author
    redirect_to '/' unless current_user.author?
  end
end
