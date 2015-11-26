class AddShippingPrice < ActiveRecord::Migration
  def change
  	add_column :items, :shipping_price, :integer, default: 0
  end
end
