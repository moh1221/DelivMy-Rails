class Request < ActiveRecord::Base
  belongs_to :user
  has_many :items
  has_one :location
  has_one :deliver
  belongs_to :category
  accepts_nested_attributes_for :items, reject_if: lambda {|attributes| attributes['ItemsName'].blank?}
  accepts_nested_attributes_for :location, reject_if: lambda {|attributes| attributes['address'].blank?}
  accepts_nested_attributes_for :location, reject_if: lambda {|attributes| attributes['Lat'].blank?}
end
