class PasswordResetsController < ApplicationController
  before_action :find_valid_reset, only: [:edit, :update]
  before_action -> { response.headers["Cache-Control"] = "no-store" }, only: [:edit, :update]

  def new
  end

  def create
    user = User.find_by(email: params[:email].to_s)
    user&.send_password_reset
    redirect_to root_path, notice: "If the address is registered, password reset instructions will be sent.", status: :see_other
  end

  def edit
  end

  def update
    changed = @user.with_lock do
      raise ActiveRecord::RecordNotFound unless valid_reset?(@user)

      if @user.update(password_params.merge(password_reset_token: nil, password_reset_sent_at: nil))
        @user.authentication_sessions.delete_all
        true
      else
        false
      end
    end

    if changed
      reset_session
      redirect_to login_path, notice: "Password has been reset!", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def find_valid_reset
    @token = params[:token]
    raise ActiveRecord::RecordNotFound unless @token.is_a?(String) && @token.match?(/\A[\w-]{43}\z/)

    @user = User.find_by!(password_reset_token: AuthenticationSession.digest(@token))
    raise ActiveRecord::RecordNotFound unless valid_reset?(@user)
  end

  def valid_reset?(user)
    user.password_reset_sent_at && user.password_reset_sent_at >= 2.hours.ago &&
      user.password_reset_token == AuthenticationSession.digest(@token)
  end

  def password_params
    values = params.expect(user: [:password, :password_confirmation])
    raise ActionController::ParameterMissing, :password if values[:password].blank?

    values
  end
end
