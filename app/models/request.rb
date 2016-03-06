class Request < ActiveRecord::Base
  belongs_to :user
  has_many :items, dependent: :destroy
  has_one :location, dependent: :destroy
  has_one :deliver, dependent: :destroy
  belongs_to :category
  has_one :profile, :through => :user

  accepts_nested_attributes_for :items, reject_if: lambda {|attributes| attributes['ItemsName'].blank?}
  accepts_nested_attributes_for :location, reject_if: lambda {|attributes| attributes['address'].blank?}
  accepts_nested_attributes_for :location, reject_if: lambda {|attributes| attributes['Lat'].blank?}

end
