class UploadsController < ApplicationController
  AVATAR_MIME_TYPES = %w[image/png image/jpeg image/gif image/webp].freeze
  MAX_AVATAR_BYTES = 5.megabytes
  before_action :require_user

  def new
    @profile = current_user.profile
    redirect_to profile_path, alert: "Create your profile first." unless @profile
  end

  def create
    @profile = current_user.profile
    upload = params[:file]
    unless @profile && upload.respond_to?(:tempfile) && upload.size.between?(1, MAX_AVATAR_BYTES)
      return redirect_to new_uploads_path, alert: "Select an image up to 5 MB.", status: :see_other
    end

    mime_type = Marcel::MimeType.for(upload.tempfile)
    unless AVATAR_MIME_TYPES.include?(mime_type)
      return redirect_to new_uploads_path, alert: "Select a PNG, JPEG, GIF, or WebP image.", status: :see_other
    end

    upload.tempfile.rewind
    @profile.avatar.attach(io: upload.tempfile, filename: File.basename(upload.original_filename),
                           content_type: mime_type, identify: false)
    redirect_to profile_path, notice: "Profile image updated.", status: :see_other
  end
end
