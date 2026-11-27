class Profile < ApplicationRecord
  belongs_to :user, inverse_of: :profile
  has_one_attached :avatar

  validates :first_name, :last_name, presence: true, length: { in: 2..30 }
end
