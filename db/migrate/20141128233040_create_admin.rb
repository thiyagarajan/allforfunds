class CreateAdmin < ActiveRecord::Migration
  def change
    create_table :admins do |t|
    	t.decimal :tax, :precision => 20, :scale => 10, :default => 0.08
    end
  end
end
