require "activemerchant"
require "stripe"

class CheckoutController < ApplicationController
	protect_from_forgery :except => [:same]
	def gateway
		@gateway ||= ActiveMerchant::Billing::PaypalExpressGateway.new(
			:login => ENV["PAYPAL_LOGIN"],
			:password => ENV["PAYPAL_PASSWORD"],
			:signature => ENV["PAYPAL_SIG"]
		)
	end
	def modify_params
		params.require(:user).permit(:email, :shipping_first_name, :shipping_last_name, :shipping_company, :shipping_address, :shipping_address_2, 
			:shipping_city, :shipping_country, :shipping_zip_code, :shipping_state, :shipping_additional_info, :shipping_phone, :billing_first_name, :billing_last_name, :billing_company, :billing_address, 
			:billing_address_2, :billing_city, :billing_state, :billing_zip_code, :billing_country, :billing_additional_info, :billing_phone, :billing_method, :additional_comments,
			:card_number, :card_name, :cvv, :expiration_date)
	end
	def shipping
		if current_user == nil then
			redirect_to "/users/sign_in"
		end
		@active = 1
		@cart = Cart.where("user_id = ? AND purchased = 0", current_user.id).first
		@user = current_user
		@us_states = us_states		
	end

	def billing
		@active = 2
		@cart = Cart.where("user_id = ? AND purchased = 0", current_user.id).first
		@user = current_user
		@us_states = us_states

		if params["user"] != nil then
			@user.update(modify_params)
		end
	end

	def payment
		if current_user == nil then
			redirect_to "/users/sign_in"
			return
		end
		@active = 3
		@cart = Cart.where("user_id = ? AND purchased = 0", current_user.id).first
		@user = current_user
		@error = params["error"]

		if params["user"] != nil then
			@user.update(modify_params)
		end
	end

	def confirm
		@active = 4
		@user = current_user
		@user.billing_method = params["method"]
	
		if params["method"] == "Stripe" then
			@user.card_number = params["Number"]
			@user.card_name = params["CardName"]
			@user.expiration_date = params["expire"] + "/" + params["year"]
			@user.cvv = params["VerificationCode"]
			@user.stripe_token = params["stripeToken"]

			if params["saveInfo"] == "on" then
				@user.save_card_info = true
			end
		else
			@user.addtional_comments = params["CommentsOrder2"]
		end
		@user.save

		@order = Cart.where("user_id = ? and purchased = 0", current_user.id).first
		@cart = @order
	end

	def check_cart (cart)
		cancel = false
		cart.items.each do |i|
			if i.purchased == 1 then
				cart.items.remove i
				cart.save
				cancel = true
			end
		end

		return cancel
	end

	def purchase_complete(cart)
		user = cart.user

		order = Order.new
		order.user = user
		puts "the cart is #{cart}"
		order.cart = cart
		order.shipping_address = user.shipping_address
		order.shipping_address_2 = user.shipping_address_2
		order.shipping_state = user.shipping_state
		order.shipping_city = user.shipping_city
		order.shipping_country = user.shipping_country
		order.shipping_first_name = user.shipping_first_name
		order.shipping_last_name = user.shipping_last_name
		order.shipping_zip_code = user.shipping_zip_code
		order.stripe_token = user.stripe_token
		order.payment_method = user.billing_method
		order.save

		if !user.save_card_info then
			user.card_number = ""
			user.cvv = ""
			user.expiration_date = ""
			user.card_name = ""
			user.save
		end

		cart.purchased = 1
		cart.save

		cart.items.each do |i|
			i.purchased = true
			i.save
		end

		@customer = user
		@order = order

		m = Mandrill::API.new 'WT6Y9B8FxGp4ptd7DxdZ4Q'
   		begin
	   		message = {
	   			:subject => "Order Confirmation",
	   			:from_name => "All For Funds",
	   			:text => "Dear #{user.billing_first_name}, \n Your order has been completed. If you believe this to be a mistake please message info@allforfunds.com.",
	   			:to => [
	   				{
	   					:email => user.email,
	   					:name => "#{user.billing_first_name} #{user.billing_last_name}"
	   				}
	   			],
	   			:html => render(:email),
	   			:from_email => "info@allforfunds.com"
	   		}
	   		m.messages.send message
	   	rescue
	   		puts "failed to send order completed email to #{user.email}"
	   	 end

	   	 begin
	   	 	message = {
	   	 		:subject => "NEW ORDER",
	   			:from_name => "Automated",
	   			:text => "Order completed from #{user.billing_first_name} #{user.billing_last_name}.",
	   			:to => [
	   				{
	   					:email => "info@allforfunds.com",
	   					:name => "Lisa"
	   				}
	   			],
	   			:html => render(:admin_email),
	   			:from_email => "info@allforfunds.com"
	   	 	}
	   	 	m.messages.send message
	   	 rescue
	   	 	puts "failed to send order to Lisa."
	   	 end
	end
	
	def purchase
		cart = Cart.where("user_id = ? and purchased = 0", current_user.id).first

		cancel = check_cart(cart)

		if cancel then
			redirect_to :controller => "checkout", :action => "payment", :error => "An item in your cart is now out of stock. It has been removed. Your checkout has been cancled. Please try again."
			return
		end

		user = current_user
		if user.billing_method == "Stripe" then

			token = current_user.stripe_token
			begin
				charge = Stripe::Charge.create(:amount => (cart.grand_total * 100).to_i, :currency => "usd", :card => token, :description => current_user.email)
				if charge == nil then
					redirect_to :controller => "checkout", :action => "payment", :error => "Card Error"
					return
				end 
				purchase_complete(cart)
			rescue Stripe::CardError => e
				redirect_to :controller => "checkout", :action => "payment", :error => e.message
				return
			end

			order = user.orders.last
			order.stripe_id = charge["id"]
			order.save

			redirect_to "/complete"
			return
		else
			subtotal = cart.total * 100
			shipping = cart.shipping_cost * 100
			tax = (cart.total + cart.shipping_cost) * Admin.first.tax * 100
			total = subtotal + shipping + tax
			puts "subtotal: #{subtotal} shipping: #{shipping} tax: #{tax} total: #{total}"
			response = gateway.setup_purchase(total,
				subtotal: subtotal,
				shipping: shipping,
				tax: tax,
				handling: 0,
				ip: request.remote_ip,
				return_url: "http://allforfunds.com/paypal/charge",
				cancel_return_url: "http://allforfunds.com/checkout/payment",
				currency: "USD",
				allow_guest_checkout: true,
				items: cart.items.map {|i| {name: i.title, description: "Clothing item", quantity: "1", amount: i.price.to_f() * 100}}			
			)

			puts "the request is: #{response.token}"

			redirect_to gateway.redirect_url_for(response.token)
		end
	end

	def pay_paypal
		cart = Cart.where("user_id = ? and purchased = 0", current_user.id).first

		cancel = check_cart(cart)

		if cancel then
			redirect_to :controller => "checkout", :action => "payment", :error => "An item in your cart is now out of stock. It has been removed. Your checkout has been cancled. Please try again."
			return
		end

		detail_response = gateway.details_for(params[:token])

		if !detail_response.success? then

		end

		subtotal = cart.total * 100
		shipping = cart.shipping_cost * 100
		tax = ((cart.total + cart.shipping_cost) * Admin.first.tax).floor
		total = subtotal + shipping + tax

		purchase = gateway.purchase(total,
			:ip => request.remote_ip,
			:payer_id => params['PayerID'],
			:token => params[:token])

		if !purchase.success? then
		end

		purchase_complete(cart)

		redirect_to "/complete"
	end

	def same
		u = current_user

		u.billing_first_name = u.shipping_first_name
		u.billing_last_name = u.shipping_last_name
		u.billing_company = u.shipping_company
		u.billing_address = u.shipping_address
		u.billing_address_2 = u.shipping_address_2
		u.billing_city = u.shipping_city
		u.billing_state = u.shipping_state
		u.billing_zip_code = u.shipping_zip_code
		u.billing_country = u.shipping_country
		u.billing_phone = u.shipping_phone
		u.save

		render nothing: true
	end

	def us_states
	    [
	      ['Alabama', 'Alabama'],
	      ['Alaska', 'Alaska'],
	      ['Arizona', 'Arizona'],
	      ['Arkansas', 'Arkansas'],
	      ['California', 'California'],
	      ['Colorado', 'Colorado'],
	      ['Connecticut', 'Connecticut'],
	      ['Delaware', 'Delaware'],
	      ['District of Columbia', 'District of Columbia'],
	      ['Florida', 'Florida'],
	      ['Georgia', 'Georgia'],
	      ['Hawaii', 'Hawaii'],
	      ['Idaho', 'Idaho'],
	      ['Illinois', 'Illinois'],
	      ['Indiana', 'Indiana'],
	      ['Iowa', 'Iowa'],
	      ['Kansas', 'Kansas'],
	      ['Kentucky', 'Kentucky'],
	      ['Louisiana', 'Louisiana'],
	      ['Maine', 'Maine'],
	      ['Maryland', 'Maryland'],
	      ['Massachusetts', 'Massachusetts'],
	      ['Michigan', 'Michigan'],
	      ['Minnesota', 'Minnesota'],
	      ['Mississippi', 'Mississippi'],
	      ['Missouri', 'Missouri'],
	      ['Montana', 'Montana'],
	      ['Nebraska', 'Nebraska'],
	      ['Nevada', 'Nevada'],
	      ['New Hampshire', 'New Hampshire'],
	      ['New Jersey', 'New Jersey'],
	      ['New Mexico', 'New Mexico'],
	      ['New York', 'New York'],
	      ['North Carolina', 'North Carolina'],
	      ['North Dakota', 'North Dakota'],
	      ['Ohio', 'Ohio'],
	      ['Oklahoma', 'Oklahoma'],
	      ['Oregon', 'Oregon'],
	      ['Pennsylvania', 'Pennsylvania'],
	      ['Puerto Rico', 'Puerto Rico'],
	      ['Rhode Island', 'Rhode Island'],
	      ['South Carolina', 'South Carolina'],
	      ['South Dakota', 'South Dakota'],
	      ['Tennessee', 'Tennessee'],
	      ['Texas', 'Texas'],
	      ['Utah', 'Utah'],
	      ['Vermont', 'Vermont'],
	      ['Virginia', 'Virginia'],
	      ['Washington', 'Washington'],
	      ['West Virginia', 'West Virginia'],
	      ['Wisconsin', 'Wisconsin'],
	      ['Wyoming', 'Wyoming']
	    ]
	end
end
