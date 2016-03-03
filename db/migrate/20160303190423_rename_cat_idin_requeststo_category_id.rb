class RenameCatIdinRequeststoCategoryId < ActiveRecord::Migration
  def change
    rename_column :requests, :CatId, :category_id
  end
end
