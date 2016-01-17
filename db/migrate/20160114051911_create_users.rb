class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, :id => false do |t|
      t.string :uuid, limit: 36, primary: true, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, null: false, :default => 2

      t.timestamps null: false
    end
    add_index :users, :email, :unique => true
    add_index :users, :uuid, :unique => true
  end
end
