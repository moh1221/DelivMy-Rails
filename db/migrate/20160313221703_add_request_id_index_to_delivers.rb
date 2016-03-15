class AddRequestIdIndexToDelivers < ActiveRecord::Migration
  def change
    add_index :delivers, :request_id
  end
end
