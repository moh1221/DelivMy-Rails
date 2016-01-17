class User < ActiveRecord::Base
  has_secure_password
  # validates :password_digest, confirmation: true
  include UuidHelper
  has_many :requests
  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: true

  def author?
    self.role == "author"
  end
end
