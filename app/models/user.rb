class User < ActiveRecord::Base
  has_secure_password

  before_create { generate_token(:auth_token)}

  validates :first_name, :last_name, :length => { :minimum => 2, maximum: 30 }, presence: true
  validates :email, uniqueness: true, presence: true
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create
  # validates :password, :length => {minimum: 8}

  include UuidHelper
  has_many :requests
  has_many :delivers
  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver_now
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def author?
    self.role == "author"
  end

end
