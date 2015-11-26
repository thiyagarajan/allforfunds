class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
    	t.belongs_to :user
    	t.integer :purchased, default: 0

      t.timestamps
    end
  end
end
