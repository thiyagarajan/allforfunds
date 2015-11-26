class CreateCartsAndItems < ActiveRecord::Migration
  def change
    create_table :carts_items do |t|
    	t.integer :cart_id
    	t.integer :item_id
    end

    drop_table :items_carts
  end
end
