class UploadsController < ApplicationController
  def new
    @user = current_user
    @profile = @user.profile
  end

  def create
    @user = current_user
    @profile = @user.profile

    # Make an object in your bucket for your upload
    obj = S3_BUCKET.objects[current_user.uuid[0..5] + DateTime.now.strftime("%Y%m%d%H%M%S") + ".jpg"]
    print("File name #############" + params[:file].original_filename)

    # Upload the file
    obj.write(
        file: params[:file],
        acl: :public_read
    )


    # Create an object for the upload
    @upload = @profile.update_attributes(
        picture: obj.public_url
    )
    redirect_to profile_path, success: 'File successfully uploaded'

  end

  def index
  end
end
