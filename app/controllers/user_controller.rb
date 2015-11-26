class UserController < ApplicationController

	before_filter :authenticate_user!

	def modify_params
		params.require(:user).permit(:email, :shipping_first_name, :shipping_last_name, :shipping_company, :shipping_address, :shipping_address_2, 
			:shipping_city, :shipping_country, :shipping_zip_code, :shipping_state, :shipping_additional_info, :shipping_phone, :billing_first_name, :billing_last_name, :billing_company, :billing_address, 
			:billing_address_2, :billing_city, :billing_state, :billing_zip_code, :billing_country, :billing_additional_info, :billing_phone, :billing_method, :additional_comments,
			:card_number, :card_name, :cvv, :expiration_date, :password, :password_confirmation, :current_password)
	end

	def account
		if current_user == nil then
			redirect_to "/users/sign_in"
			return
		end 
	end

	def orders
		if current_user == nil then
			redirect_to "/users/sign_in"
			return
		end

		puts "Current user is: #{current_user.id}"

		@orders = Order.where("user_id = ?", current_user.id)

		@empty = false
		if @orders.first == nil then
			@empty = true
		end
	end

	def address
		if current_user == nil then
			redirect_to "/users/sign_in"
			return
		end

		@user = current_user
	end

	def information
		if current_user == nil then
			redirect_to "/users/sign_in"
			return
		end

		@error = params["error"]
		@user = current_user
	end

	def update
		if current_user == nil then
			redirect_to "/users/sign_in"
			return
		end
		user = current_user

		if params["user"]["password"] == nil then
			user.update(modify_params)
		else
			if user.update_with_password(modify_params) then
				sign_in user, :bypass => true
			else 
				puts "It is a failure :("
				redirect_to :action => "information", :error => "Something went wrong saving your information. Did you enter the currect password?"
				return
			end
		end


		if params["redirect"] == nil then
			redirect_to "/account"
			return
		end

		redirect_to params["redirect"]
	end
end
