class RenameStatusToStatusInfo < ActiveRecord::Migration
  def change
    rename_column :statuses, :status, :status_info
  end
end
