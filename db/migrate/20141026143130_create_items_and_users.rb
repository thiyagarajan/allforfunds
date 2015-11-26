class CreateItemsAndUsers < ActiveRecord::Migration
  def change
    create_table :items_carts, id: false do |t|
    	t.belongs_to :carts
    	t.belongs_to :items
    end
  end
end
