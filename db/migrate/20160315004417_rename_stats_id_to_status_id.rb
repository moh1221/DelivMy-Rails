class RenameStatsIdToStatusId < ActiveRecord::Migration
  def change
    rename_column :requests, :StatId, :status_id
  end
end
