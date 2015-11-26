class CartController < ApplicationController
	skip_before_filter  :verify_authenticity_token
	def show
		if not user_signed_in? then
			render html: "<h2> Please Login to view your cart </h2>".html_safe
			return
		end

		@cart = Cart.where("user_id = ? and purchased = 0", current_user.id).first
		@error = params["error"]

		render :cart
	end

	def add_to_cart
		if params["item_id"] == nil then
			render json: {"error" => "Please specifiy Item ID"}
		end

		item_to_add = Item.find(params["item_id"])
		if item_to_add == nil then
			render json: {"error" => "Invalid Item ID"}
		end

		cart = nil
		if user_signed_in? then
			cart = Cart.where("user_id = ? AND purchased = 0", current_user.id).first

			if cart == nil then
				cart = Cart.new
				cart.user = current_user
			end
		else
			render json: {"error" => "Please login to add items to the cart"}
			return
		end

		cart.items << item_to_add
		cart.save

		render json: {"error" => nil}
	end

	def remove_from_cart
		if params["item_id"] == nil then
			render json: {"error" => "Please specifiy Item ID"}
		end

		item_to_remove = Item.find params["item_id"]
		if item_to_remove == nil then
			render json: {"error" => "Invalid Item ID"}
		end

		if user_signed_in? then
			cart = Cart.where("user_id = ? AND purchased = 0", current_user.id).first

			if cart == nil then
				render json: {"error" => "Could not find cart"}
			end

			cart.items.delete item_to_remove
			cart.save
		else
			render json: {"error" => "Please login to remove items from cart"}
		end

		render json: {"error" => nil}
	end
end
