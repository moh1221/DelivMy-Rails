class RenameStatusToStatusInfo < ActiveRecord::Migration[4.2]
  def change
    rename_column :statuses, :status, :status_info
  end
end
