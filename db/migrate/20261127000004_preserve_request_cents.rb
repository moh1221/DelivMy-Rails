class PreserveRequestCents < ActiveRecord::Migration[8.1]
  def up
    change_column :requests, :cost, :decimal, precision: 12, scale: 2
    change_column :requests, :fees, :decimal, precision: 12, scale: 2
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Scale zero would discard cents from new requests."
  end
end
