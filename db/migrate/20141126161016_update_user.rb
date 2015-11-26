class UpdateUser < ActiveRecord::Migration
  def change
  	add_column :users, :shipping_first_name, :string
  	add_column :users, :shipping_last_name, :string
  	add_column :users, :shipping_company, :string
  	add_column :users, :shipping_address, :string
  	add_column :users, :shipping_address_2, :string
  	add_column :users, :shipping_city, :string
  	add_column :users, :shipping_state, :string
  	add_column :users, :shipping_zip_code, :string
  	add_column :users, :shipping_country, :string
  	add_column :users, :shipping_additional_info, :text
  	add_column :users, :shipping_phone, :string

  	add_column :users, :billing_first_name, :string
  	add_column :users, :billing_last_name, :string
  	add_column :users, :billing_company, :string
  	add_column :users, :billing_address, :string
  	add_column :users, :billing_address_2, :string
  	add_column :users, :billing_city, :string
  	add_column :users, :billing_state, :string
  	add_column :users, :billing_zip_code, :string
  	add_column :users, :billing_country, :string
  	add_column :users, :billing_additional_info, :text
  	add_column :users, :billing_phone, :string
  	add_column :users, :billing_method, :string

  	add_column :users, :addtional_comments, :string
  	
  	add_column :users, :card_number, :string
  	add_column :users, :card_name, :string
  	add_column :users, :cvv, :string
  	add_column :users, :expiration_date, :string
  end
end
