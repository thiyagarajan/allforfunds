class ItemDecimal < ActiveRecord::Migration
  def change
  	change_column :items, :price, :decimal, :precision => 20, :scale => 2
  end
end
