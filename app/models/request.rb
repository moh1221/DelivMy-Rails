class Request < ActiveRecord::Base
  belongs_to :user
  has_many :items, dependent: :destroy
  has_one :location, dependent: :destroy
  has_one :deliver, dependent: :destroy
  belongs_to :category
  belongs_to :status
  has_one :profile, :through => :user

  acts_as_mappable :through => :location

  accepts_nested_attributes_for :items, reject_if: lambda {|attributes| attributes['ItemsName'].blank?}
  accepts_nested_attributes_for :location, reject_if: lambda {|attributes| attributes['address'].blank?}
  accepts_nested_attributes_for :location, reject_if: lambda {|attributes| attributes['Lat'].blank?}

  validates :PlaceName, :cost, :fees, presence: true


  scope :request_deliver_select, -> { select(:id, :PlaceName, :created_at, :cost, :fees, :delivery_at, :first_name, :last_name, :email, :CatName, :picture, :Lat, :Long, :receipt_img ) }
  scope :current_delivery, ->(current) { joins(:deliver, :profile, :category, :location).where('delivers.user_id = ?', current ) }
  scope :recent_deliver , -> { order('delivers.request_id desc') }

  # Search
  valData = [:id, :PlaceName, :created_at, :cost, :fees, :delivery_at, :first_name, :last_name, :email, :CatName, :picture, :Lat, :Long, :address]
  scope :selected_val, -> { select(valData) }
  scope :search_filter, -> (current) { where('requests.delivery_at > ? and requests.user_id != ? and requests.status_id = 1', DateTime.now, current) }
  scope :search_joins, -> { joins(:profile, :category, :location).includes(:items)}
  scope :search_includes, -> { joins(:location).includes(:items, :category, :location ) }
  scope :search_order, -> { order("requests.id DESC") }

end
