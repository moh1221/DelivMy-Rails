module ProfileImagesHelper
  def profile_image_path(profile)
    return if profile.nil?
    return rails_storage_proxy_path(profile.avatar, only_path: true) if profile.avatar.attached?

    safe_https_url(profile.picture)
  end

  def safe_https_url(value)
    uri = URI.parse(value.to_s)
    value if uri.is_a?(URI::HTTPS) && uri.host.present? && !uri.userinfo
  rescue URI::InvalidURIError
    nil
  end
end
