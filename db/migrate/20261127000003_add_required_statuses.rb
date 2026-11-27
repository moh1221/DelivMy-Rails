class AddRequiredStatuses < ActiveRecord::Migration[8.1]
  class LegacyStatus < ActiveRecord::Base
    self.table_name = "statuses"
  end

  def up
    LegacyStatus.find_or_create_by!(id: 1) { |status| status.status_info = "Open" }
    LegacyStatus.find_or_create_by!(id: 2) { |status| status.status_info = "On Progress" }
  end

  def down
    # Keep status records that legacy requests and deliveries may refer to.
  end
end
