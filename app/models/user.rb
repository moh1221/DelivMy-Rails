class User < ApplicationRecord
  self.primary_key = :uuid

  has_secure_password reset_token: false
  before_validation :assign_uuid, on: :create
  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: :password_digest_changed?
  validates :profile, presence: true, on: :create

  has_many :requests, inverse_of: :user
  has_many :delivers, inverse_of: :user
  has_many :authentication_sessions, dependent: :delete_all, inverse_of: :user
  has_one :profile, inverse_of: :user, dependent: :destroy
  accepts_nested_attributes_for :profile, update_only: true

  def send_password_reset
    token = SecureRandom.urlsafe_base64(32)
    update!(password_reset_token: AuthenticationSession.digest(token), password_reset_sent_at: Time.current)
    UserMailer.password_reset(self, token).deliver_now
  end

  private

  def assign_uuid
    self.uuid ||= SecureRandom.uuid.upcase
  end
end
