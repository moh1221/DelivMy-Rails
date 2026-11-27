class AuthenticationSession < ApplicationRecord
  BROWSER_DURATION = 12.hours
  REMEMBERED_DURATION = 30.days

  belongs_to :user
  scope :active, -> { where(expires_at: Time.current..) }

  def self.issue!(user, remember: false)
    token = SecureRandom.urlsafe_base64(32)
    duration = remember ? REMEMBERED_DURATION : BROWSER_DURATION
    create!(user: user, token_digest: digest(token), expires_at: duration.from_now)
    token
  end

  def self.lookup(token)
    return unless token.is_a?(String) && token.match?(/\A[\w-]{43}\z/)

    active.includes(:user).find_by(token_digest: digest(token))
  end

  def self.digest(token)
    Digest::SHA256.hexdigest(token)
  end
end
