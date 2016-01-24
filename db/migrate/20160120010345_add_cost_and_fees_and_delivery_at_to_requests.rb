class AddCostAndFeesAndDeliveryAtToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :cost, :decimal
    add_column :requests, :fees, :decimal
    add_column :requests, :delivery_at, :datetime
  end
end
