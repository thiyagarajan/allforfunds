class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
    	t.string :eId, null: false
    	t.string :title
    	
      t.timestamps
    end
  end
end
