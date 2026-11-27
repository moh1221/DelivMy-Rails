class Item < ApplicationRecord
  belongs_to :request, inverse_of: :items
  validates :ItemsName, presence: true
  normalizes :ItemDescription, with: ->(value) { value.to_s }, apply_to_nil: true
end
