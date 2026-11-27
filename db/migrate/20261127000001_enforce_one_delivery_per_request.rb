class EnforceOneDeliveryPerRequest < ActiveRecord::Migration[8.1]
  def up
    duplicates = select_value("SELECT COUNT(*) FROM (SELECT request_id FROM delivers GROUP BY request_id HAVING COUNT(*) > 1) duplicate_requests")
    if duplicates.to_i.positive?
      raise "Found #{duplicates} request(s) with competing delivery assignments. Back up and reconcile them before adding the unique index."
    end

    add_index :delivers, :request_id, unique: true, name: :index_delivers_on_unique_request_id
    remove_index :delivers, name: :index_delivers_on_request_id
  end

  def down
    add_index :delivers, :request_id, name: :index_delivers_on_request_id
    remove_index :delivers, name: :index_delivers_on_unique_request_id
  end
end
