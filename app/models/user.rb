class User < ActiveRecord::Base
  has_secure_password
  include UuidHelper
  has_many :requests

  def author?
    self.role == "author"
  end
end
