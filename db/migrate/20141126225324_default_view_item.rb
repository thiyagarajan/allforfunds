class DefaultViewItem < ActiveRecord::Migration
  def change
  	change_column :items, :views, :integer, :default => 0
  end
end
