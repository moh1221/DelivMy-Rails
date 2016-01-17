module UuidHelper
  def self.included(base)
    base.primary_key = 'uuid'
    base.before_create :assign_uuid
  end

  private
  def assign_uuid
    self.uuid = UUIDTools::UUID.timestamp_create().to_s.upcase if uuid.blank?
  end
end