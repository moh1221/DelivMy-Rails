class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.integer :request_id, null: false
      t.text :ItemsName, null: false
      t.text :ItemDescription, null: false

      t.timestamps null: false
    end
  end
end
