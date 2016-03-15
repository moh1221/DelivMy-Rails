class RenameDelivStatusToStatusId < ActiveRecord::Migration
  def change
    rename_column :delivers, :deliv_Status, :status_id
  end
end
