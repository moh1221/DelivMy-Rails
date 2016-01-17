class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :user_id, null: false
      t.integer :LocId, null: false
      t.string :PlaceName, null: false
      t.integer :StatId, null: false
      t.integer :CatId, null: false


      t.timestamps null: false
    end
  end
end
