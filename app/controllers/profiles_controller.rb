class ProfilesController < ApplicationController
  def index
  end

  def show
    @user = current_user
    @profile = @user.profile
    @requests = Request.where(user_id: current_user.uuid).count
    @delivers = Deliver.where(user_id: current_user.uuid).count
  end

  def new
  end

  def update
    @user = current_user
    @user.profile.update_attributes(profile_params)
    redirect_to user_path
  end

  private
  def profile_params
    params.require(:user).permit(:picture, :work, :home)
  end
end
