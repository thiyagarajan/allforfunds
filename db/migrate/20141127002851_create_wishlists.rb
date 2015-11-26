class CreateWishlists < ActiveRecord::Migration
  def change
    create_table :wishlists do |t|
    	t.belongs_to :user
    	
      t.timestamps
    end
  end
end
