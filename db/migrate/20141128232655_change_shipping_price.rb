class ChangeShippingPrice < ActiveRecord::Migration
  def change
  	change_column :items, :shipping_price, :decimal, :precision => 20, :scale => 2
  end
end
