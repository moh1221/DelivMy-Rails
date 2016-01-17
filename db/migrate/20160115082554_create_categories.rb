class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :CatName, null: false
    end
  end
end
