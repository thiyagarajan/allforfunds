class AddItemViewCount < ActiveRecord::Migration
  def change
  	add_column :items, :views, :integer
  end
end
