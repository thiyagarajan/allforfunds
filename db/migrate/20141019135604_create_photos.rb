class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
    	t.belongs_to :item
    	t.string :url, null: false
    	t.integer :is_gallery, default: 0

      t.timestamps
    end
  end
end
