class CreateDelivers < ActiveRecord::Migration
  def change
    create_table :delivers do |t|
      t.integer :request_id, null: false
      t.string :user_id, null: false
      t.integer :deliv_Status, null: false
      t.string :receipt_img
      t.datetime :completed_at

      t.timestamps null: false
    end
  end
end
