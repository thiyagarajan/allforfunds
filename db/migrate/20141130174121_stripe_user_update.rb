class StripeUserUpdate < ActiveRecord::Migration
  def change
  	add_column :users, :save_card_info, :boolean, :default => false
  	add_column :users, :stripe_token, :string
  end
end
