class User < ActiveRecord::Base
  has_secure_password

  validates :first_name, :last_name, :length => { :minimum => 2, maximum: 30 }, presence: true
  validates :email, uniqueness: true, presence: true
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create
  validates :password, length: { minimum: 8 }

  include UuidHelper
  has_many :requests
  has_many :delivers
  has_one :profile
  accepts_nested_attributes_for :profile
  def author?
    self.role == "author"
  end
end
