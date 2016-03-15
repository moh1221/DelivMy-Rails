class UsersController < ApplicationController


  def new
    @user = User.new
    @user.build_profile
  end

  def create
    @user = User.create(user_params)

    if @user.save
      WelcomeMailer.sample_email(@user).deliver_now
      redirect_to login_path, notice: "You have been successfully registered"
    else
      render 'new'
    end
  end

  def show
    @user = current_user
  end

  def update
    @user = current_user
    @user.update_attributes(user_params)
    redirect_to user_path
  end

  private
  def user_params
    params.require(:user).permit( :email, :password, :password_confirmation, profile_attributes: [:first_name, :last_name, :picture, :home, :work])
  end
end
