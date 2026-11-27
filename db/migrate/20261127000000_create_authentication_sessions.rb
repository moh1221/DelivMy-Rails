class CreateAuthenticationSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :authentication_sessions do |t|
      t.string :user_id, null: false, limit: 36, index: true
      t.string :token_digest, null: false, limit: 64, index: { unique: true }
      t.datetime :expires_at, null: false, index: true
      t.timestamps
    end
    add_index :requests, :user_id
    add_index :delivers, :user_id
  end
end
