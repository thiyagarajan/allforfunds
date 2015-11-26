class WishlistController < ApplicationController
	protect_from_forgery :except => [:add, :remove]
	
	def show
		if current_user == nil then
			redirect "/login"
		end

		@wishlist = Wishlist.where("user_id = ?", current_user).first
		render :wishlist
	end
	def add
		if params["item_id"] == nil then
			render json: {"error" => "Please specifiy Item ID"}
		end

		item_to_add = Item.find(params["item_id"])
		if item_to_add == nil then
			render json: {"error" => "Invalid Item ID"}
		end

		wishlist = nil
		if user_signed_in? then
			wishlist = Wishlist.where("user_id = ?", current_user.id).first

			if wishlist == nil then
				wishlist= Wishlist.new
				wishlist.user = current_user
				wishlist.save
			end
		else
			render json: {"error" => "Please login to add items to the wishlist"}
			return
		end

		wishlist.items << item_to_add
		wishlist.save

		render json: {"error" => nil}
	end

	def remove
		if params["item_id"] == nil then
			render json: {"error" => "Please specifiy Item ID"}
		end

		item_to_remove = Item.find params["item_id"]
		if item_to_remove == nil then
			render json: {"error" => "Invalid Item ID"}
		end

		if user_signed_in? then
			wishlist = Wishlist.where("user_id = ?", current_user.id).first

			if wishlist == nil then
				render json: {"error" => "Could not find cart"}
			end

			wishlist.items.delete item_to_remove
			wishlist.save
		else
			render json: {"error" => "Please login to remove items from cart"}
		end

		render json: {"error" => nil}
	end
end
