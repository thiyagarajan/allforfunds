class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
    	t.belongs_to :cart
    	t.belongs_to :user

    	t.string :shipping_address 
		t.string :shipping_address_2 
		t.string :shipping_state 
		t.string :shipping_city
		t.string :shipping_country 
		t.string :shipping_first_name 
		t.string :shipping_last_name 
		t.string :shipping_zip_code 
		t.string :stripe_token 
		t.string :payment_method
		t.string :stripe_id
		t.string :paypal_id

      t.timestamps
    end
  end
end
