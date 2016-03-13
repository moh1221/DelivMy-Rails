class Profile < ActiveRecord::Base
  belongs_to :user
  validates :first_name, :last_name, :length => { :minimum => 2, maximum: 30 }, presence: true
end
