class ChangeEidToString < ActiveRecord::Migration
  def change
  	change_column :items, :eId, :string
  end
end
