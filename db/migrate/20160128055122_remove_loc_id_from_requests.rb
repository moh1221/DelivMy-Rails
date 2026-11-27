class RemoveLocIdFromRequests < ActiveRecord::Migration[4.2]
  def change
    remove_column :requests, :LocId, :integer
  end
end
