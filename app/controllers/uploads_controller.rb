class UploadsController < ApplicationController

  def new
    @profile = Profile.find_by(user_id: current_user.uuid)
  end

  def create
    @profile = Profile.find_by(user_id: current_user.uuid)

    if !params[ :file ].nil?
      # Make an object in your bucket for your upload
      obj = S3_BUCKET.objects[current_user.uuid[0..5] + DateTime.now.strftime("%Y%m%d%H%M%S") + ".jpg"]

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
    else
      redirect_to new_uploads_path
    end
  end

  def index
  end
end
