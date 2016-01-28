class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.integer :request_id, null: false
      t.string :address, null: false
      t.float :Lat, null: false
      t.float :Long, null: false

      t.timestamps null: false
    end
  end
end
