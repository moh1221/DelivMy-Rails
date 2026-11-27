class SessionsController < ApplicationController
  before_action :require_user, only: :destroy
  skip_forgery_protection if: -> { (action_name == "create" && native_sign_in?) || (action_name == "destroy" && bearer_authenticated?) }
  after_action :set_csrf_header, only: [:new, :create]
  before_action :prevent_caching

  def new
  end

  def create
    credentials = params.expect(session: [:email, :password, :remember_me])
    user = User.authenticate_by(email: credentials[:email].to_s, password: credentials[:password].to_s)
    unless user
      return respond_to do |format|
        format.html { flash.now.alert = "Invalid email or password."; render :new, status: :unprocessable_content }
        format.json { render json: { error: "Invalid email or password." }, status: :unauthorized }
      end
    end

    current_authentication&.destroy! unless native_sign_in?
    remember_value = credentials.fetch(:remember_me, nil) || params[:remember_me]
    remember = request.format.json? || ActiveModel::Type::Boolean.new.cast(remember_value)
    token = AuthenticationSession.issue!(user, remember: remember)
    unless native_sign_in?
      reset_session
      session[:auth_token] = token
      request.session_options[:expire_after] = AuthenticationSession::REMEMBERED_DURATION if remember
    end

    respond_to do |format|
      format.html { redirect_to search_path, status: :see_other }
      format.json { render json: { session: { id: token, user_id: user.id } } }
    end
  end

  def destroy
    current_authentication.destroy!
    reset_session unless bearer_token.present?
    respond_to do |format|
      format.html { redirect_to root_path, status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Native clients do not send browser-origin metadata or cookies on sign-in.
  # Browser submissions (including simple cross-site forms) require Rails CSRF checks.
  def native_sign_in?
    request.format.json? && request.media_type == "application/json" &&
      request.headers["Origin"].blank? && request.headers["Sec-Fetch-Site"].blank? &&
      request.headers["Cookie"].blank?
  end

  def set_csrf_header
    response.headers["XSRF-TOKEN"] = form_authenticity_token unless native_sign_in?
  end

  def prevent_caching
    response.headers["Cache-Control"] = "no-store"
  end
end
