class UsersController < ApplicationController
  before_action :require_user, only: [:show, :update]

  def new
    @user = User.new
    @user.build_profile
  end

  def create
    @user = User.new(signup_params)

    if @user.save
      WelcomeMailer.sample_email(@user).deliver_later if Rails.configuration.action_mailer.perform_deliveries
      redirect_to login_path, notice: "You have been successfully registered.", status: :see_other
    else
      @user.build_profile unless @user.profile
      render :new, status: :unprocessable_content
    end
  end

  def show
    @user = current_user
  end

  def update
    @user = current_user
    update_params = params.expect(user: [:email, :password, :password_confirmation, :current_password])
    unless @user.authenticate(update_params.delete(:current_password).to_s)
      return redirect_to user_path, alert: "Current password is required.", status: :see_other
    end

    changed_password = update_params[:password].present?
    User.transaction do
      @user.update!(update_params)
      @user.authentication_sessions.delete_all if changed_password
    end
    reset_session if changed_password
    redirect_to(changed_password ? login_path : user_path, notice: "Account updated.", status: :see_other)
  rescue ActiveRecord::RecordInvalid
    render :show, status: :unprocessable_content
  end

  private

  def signup_params
    params.expect(user: [:email, :password, :password_confirmation,
                                 profile_attributes: [:first_name, :last_name, :home, :work]])
  end
end
