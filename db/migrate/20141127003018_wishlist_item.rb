class WishlistItem < ActiveRecord::Migration
  def change
  	create_table :wishlists_items do |t|
    	t.integer :wishlist_id
    	t.integer :item_id
    end
  end
end
