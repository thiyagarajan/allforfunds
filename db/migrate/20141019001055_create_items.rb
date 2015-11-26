class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
    	t.integer :eId, null: false
    	t.string :title, null: false
    	t.decimal :price, null: false
    	t.string :url
    	t.belongs_to :category

      t.timestamps
    end
  end
end
