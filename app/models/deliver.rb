class Deliver < ActiveRecord::Base
  before_create :set_deliv_status

  belongs_to :user
  belongs_to :request
  belongs_to :status
  has_one :profile, :through => :user


  scope :recent, -> { order(:request_id)}


  protected

  def set_deliv_status
    self.deliv_Status = 1
  end

end
