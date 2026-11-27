class RenameCatIdinRequeststoCategoryId < ActiveRecord::Migration[4.2]
  def change
    rename_column :requests, :CatId, :category_id
  end
end
