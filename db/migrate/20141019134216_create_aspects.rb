class CreateAspects < ActiveRecord::Migration
  def change
    create_table :aspects do |t|
    	t.string :name, null: false
    	t.string :value
    	t.belongs_to :category
    	t.belongs_to :item

      t.timestamps
    end
  end
end
