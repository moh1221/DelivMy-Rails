class RenameDelivStatusToStatusId < ActiveRecord::Migration[4.2]
  def change
    rename_column :delivers, :deliv_Status, :status_id
  end
end
