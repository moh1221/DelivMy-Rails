class Request < ActiveRecord::Base
  belongs_to :user
  has_many :items
  has_one :location
  accepts_nested_attributes_for :items, reject_if: lambda {|attributes| attributes['ItemsName'].blank?}
  accepts_nested_attributes_for :location, reject_if: lambda {|attributes| attributes['address'].blank?}
end
