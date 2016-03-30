class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token, if: :json_request?

  helper_method :current_user

  protected

  def json_request?
    request.format.json?
  end

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
