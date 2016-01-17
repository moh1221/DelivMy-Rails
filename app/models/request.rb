class Request < ActiveRecord::Base
  belongs_to :user
  has_many :items
  accepts_nested_attributes_for :items, allow_destroy: true, reject_if: lambda {|attributes| attributes['ItemsName'].blank?}
end
