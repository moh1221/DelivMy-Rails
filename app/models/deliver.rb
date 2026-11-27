class Deliver < ApplicationRecord
  belongs_to :user, inverse_of: :delivers
  belongs_to :request, inverse_of: :deliver
  belongs_to :status
  has_one :profile, through: :user
end
