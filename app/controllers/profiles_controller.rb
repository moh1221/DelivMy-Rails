class ProfilesController < ApplicationController
  before_action :require_user

  def show
    @user = current_user
    @profile = @user.profile || @user.build_profile
    @requests = @user.requests.count
    @delivers = @user.delivers.count
  end

  def update
    @user = current_user
    @profile = @user.profile || @user.build_profile
    if @profile.update(params.expect(profile: [:first_name, :last_name, :home, :work]))
      redirect_to profile_path, notice: "Profile updated.", status: :see_other
    else
      @requests = @user.requests.count
      @delivers = @user.delivers.count
      flash.now.alert = @profile.errors.full_messages.to_sentence
      render :show, status: :unprocessable_content
    end
  end
end
