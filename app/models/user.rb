class User < ActiveRecord::Base
  has_secure_password
  # validates :password_digest, confirmation: true
  include UuidHelper
  has_many :requests

  def author?
    self.role == "author"
  end
end
