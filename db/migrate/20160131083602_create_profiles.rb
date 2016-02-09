class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :first_name
      t.string :last_name
      t.string :picture
      t.string :home
      t.string :work
      t.string :user_id, null: false

      t.timestamps null: false
    end
  end
end
