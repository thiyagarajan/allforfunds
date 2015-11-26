class AddPurchasedItem < ActiveRecord::Migration
  def change
  	add_column :items, :purchased, :boolean, default: false
  end
end
