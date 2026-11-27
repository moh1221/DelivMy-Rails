class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_authenticity_token
  rescue_from ActionController::ParameterMissing do |error|
    if request.format.json?
      render json: { error: error.message }, status: :bad_request
    else
      head :bad_request
    end
  end

  private

  def bearer_token
    return unless request.format.json?

    request.authorization.to_s[/\ABearer (\S+)\z/i, 1]
  end

  def current_authentication
    return @authentication_session if defined?(@authentication_session)

    @authentication_session = AuthenticationSession.lookup(bearer_token || session[:auth_token])
  end

  def current_user
    current_authentication&.user
  end

  def bearer_authenticated?
    bearer_token.present? && current_authentication.present?
  end

  def require_user
    return if current_user

    if request.format.json?
      render json: { error: "Sign in required." }, status: :unauthorized
    else
      redirect_to login_path, alert: "Please sign in."
    end
  end

  def not_found
    request.format.json? ? render(json: { error: "Not found." }, status: :not_found) : head(:not_found)
  end

  def invalid_authenticity_token
    request.format.json? ? render(json: { error: "Invalid request verification token." }, status: :forbidden) : head(:forbidden)
  end

  def readable_request(id)
    order = Request.find(id)
    raise ActiveRecord::RecordNotFound unless order.readable_by?(current_user)

    order
  end

  def render_conflict(message, redirect:)
    if request.format.json?
      render json: { error: message }, status: :conflict
    else
      redirect_to redirect, status: :see_other, alert: message
    end
  end
end
