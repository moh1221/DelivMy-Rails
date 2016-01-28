class RemoveLocIdFromRequests < ActiveRecord::Migration
  def change
    remove_column :requests, :LocId, :integer
  end
end
