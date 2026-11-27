class RenameStatsIdToStatusId < ActiveRecord::Migration[4.2]
  def change
    rename_column :requests, :StatId, :status_id
  end
end
