require 'mandrill'

class ShopController < ApplicationController
	skip_before_filter :verify_authenticity_token
	def index
	end
	def authenticity
	end
	def about
	end
	def returns
	end
	def privacy
	end
	def terms
	end
	def sell
	end
	def contact
	end
	def nav
            render :partial => "layouts/nav"
   	end
   	def send_contact_email

   		m = Mandrill::API.new 'WT6Y9B8FxGp4ptd7DxdZ4Q'
   		begin
	   		message = {
	   			:subject => params["subject"],
	   			:from_name => params["firstname"] + params["lastname"],
	   			:text => params["comment"],
	   			:to => [
	   				{
	   					:email => "info@allforfunds.com",
	   					:name => "Info"
	   				}
	   			],
	   			:from_email => params["email"]
	   		}
	   		m.messages.send message
	   	rescue
	   		render :text => "Failed to send email. Please send your comments and concerns to info@allforfunds.com."
	   	 	return
	   	 end

   		render :text => "Your message has been sent successfully. We will contact you shortly."
   	end
   	def sell_sign_up
   		m = Mandrill::API.new 'WT6Y9B8FxGp4ptd7DxdZ4Q'
   		begin
	   		message = {
	   			:subject => "NEW SELLER",
	   			:from_name => "Automated",
	   			:text => "Name: #{params["firstname"] + params["lastname"]} 
	   			Email: #{params["email"]}
	   			Phone: #{params["phone"]} 
	   			Address: #{params["address"]} 
	   			City: #{params["city"]}
	   			State: #{params["state"]} 
	   			Zip: #{params["zip"]}",
	   			:to => [
	   				{
	   					:email => "info@allforfunds.com",
	   					:name => "Info"
	   				}
	   			],
	   			:from_email => "info@allforfunds.com"
	   		}
	   		m.messages.send message
	   	rescue
	   		render :text => "Failed to send email. Please send your information to info@allforfunds.com."
	   	 	return
	   	 end

   		render 'shop/terms'
   	end
   	
	def shop

		@results = nil

		items = []
		aspects = {}
		aspect_names = []
		checked_aspect_names = []
		categories = []
		category = nil

		if params[:search] != nil then

			Rebay::Api.configure do |r|
				r.app_id = 'AllForFu-8c44-42d9-8f97-90711eb79c87'
			end

			finder = Rebay::Finding.new

			if params[:search] == nil then
				@results = {"error" => "Search for items with keywords!"}
				return
			end

			response = finder.find_items_by_keywords({:keywords => params[:search],
			"itemFilter(0).name"=>"Seller", "itemFilter(0).value(0)" => "allforfunds"}).response

			if response["ack"] != "Success" then
				puts "Search failed: \n #{response}"
				return
			end

			search_results = response["searchResult"]
			if search_results["@count"] == 0 then
				@results = {"error" => "no results"}
				@categories = {}
				@aspects = {}
				@aspect_names = []
				@items = []
				@selected_categories = []
				@cart = nil
				if current_user != nil then
					@cart = Cart.where("user_id = ? AND purchased = 0", current_user.id).first
				end
				return
			end
			ebay_items = search_results["item"]

			if ebay_items == nil then
				@results = {"error" => "no results"}
				@categories = {}
				@aspects = {}
				@aspect_names = []
				@items = []
				@selected_categories = []
				@cart = nil
				if current_user != nil then
					@cart = Cart.where("user_id = ? AND purchased = 0", current_user.id).first
				end
				return
			end

			if ebay_items.kind_of?(Hash) then
				#there is only one result so we are just gonna direct them to it.

				i = Item.where("eId = ?", ebay_items["itemId"]).first
				return redirect_to "/items/#{i.id}"
			end

			ebay_items.each do |ebay_item|
				if ebay_item["itemId"] == nil then
					#not a valid item - just ignore it

					next
				end

				item = Item.where("eId = ?", ebay_item["itemId"]).first
				if item == nil then
					#item is an item that is not kept on the online store - ignore it

					next
				end
				if category != nil and item.category != category then
					next
				end

				items << item
				if not categories.include? item.category then
					categories << item.category
				end
			end
		else

		   relation_items = Item.where("purchased = false")
		   if params[:price] == nil then
				relation_items.each do |item|
					items << item
				end
			else
				base_price = params["price"].to_f
				relation_items.each do |item|
					if item.price < base_price
						items << item 
					end
				end
			end
		end

		if params["category"] != nil then
			# The category comes in something that is similar to the category name
			# This means there can be multiple categories
			# Get all the possible objects from the categories and intersect it with the items
			possible_items = []
			categories = Category.where("title LIKE ?", "#{params["category"]}%")

			categories.each do |category|
				category.items.each do |item|
					possible_items << item
				end
			end 

			items = items & possible_items
		end

		#make sure there are still items
		if items.size == 0 then
			@results = {"error" => "no results"}
			@categories = {}
			@aspects = {}
			@aspect_names = []
			@items = []
			@selected_categories = []
			@cart = nil
			if current_user != nil then
				@cart = Cart.where("user_id = ? AND purchased = 0", current_user.id).first
			end
			return
		end

		if params["aspects"] != nil and params["values"] != nil then
			search_aspects = params["aspects"].split(",")
			search_values = params["values"].split(",")
			if search_aspects.size != search_values.size then
				@results = {"error" => "Aspect parameter must be the same as value parameter"}
				return
			end


			# Parse all the requested aspects into one hash
			# This hash is used so that multiple aspects can have multiple values
			# For example, someone can search for the color brown and the color green
			# The array is needed so there are no duplicates when sorting through the array in the next step 
			aspects_hash = {}
			search_aspect_names = search_aspects & search_aspects
			(0..search_values.size-1).each do |i|
				if aspects_hash[search_aspects[i]] != nil then
					aspects_hash[search_aspects[i]] << search_values[i]
				else
					aspects_hash[search_aspects[i]] = []
					aspects_hash[search_aspects[i]] << search_values[i]
				end
			end

			# The hash created about is filtered through.
			# It finds aspects with the name and values and adds the item they belong to to an array.
			# The array is then interesected with the list of items returned by Ebay.
			search_aspect_names.each do |aspect_name|
				possible_items = []
				aspects_hash[aspect_name].each do |value|
					Aspect.where("name = ? AND value = ?", aspect_name, value).each do |aspect|
						possible_items << aspect.item
					end
				end

				items = items & possible_items
			end
		end

		# Set up all possible aspects for the filter on the left
		# Begin with the aspects of the first object
		# The add aspects that are common and remove aspects are not
		# The result is stored in a hash like this: {"Size" => [1,2,3]}
		# If there is only one category then we will just default to those aspects
		if categories.size != 1 then
			items.each do |item|
				item.aspects.each do |aspect|
					if aspects[aspect.name] == nil then
						aspects[aspect.name] = [aspect.value]
					else
						if !aspects[aspect.name].include? aspect.value then
							aspects[aspect.name] << aspect.value
							aspects[aspect.name].uniq!
						end
					end
				end
			end
		else
			#create a list of all aspect names and a hash of all aspect values
			categories[0].aspects.each do |aspect|
				if aspect_names.include? aspect.name then
					unless aspects[aspect.name].include? aspect.value then
						aspects[aspect.name] << aspect.value
					end
				else
					aspect_names << aspect.name
					aspects[aspect.name] = [aspect.value]
				end
			end
		end

		if categories.first == nil then
			categories = Category.all
		end

		category_hash = {}
		categories.each do |category|
			sub_categories = category.title.split(":")

			if category_hash.keys.include? sub_categories[1] then
				category_hash[sub_categories[1]] << sub_categories[2]
				category_hash[sub_categories[1]].uniq
				next
			end

			category_hash[sub_categories[1]] = [sub_categories[2]]
		end

		# Sort through the newly created hash key.
		# Delete any key that has only one element 
		aspects.delete_if { |k,v| v.size < 2 }

		sorted_aspects = {}
		aspects.sort.each do |aspect|
			if aspect[0] == "Brand" then
				sorted_aspects[aspect[0]] = aspect[1].sort
			end
		end
		aspects.sort.each do |aspect|
			if aspect[0] != "Brand" then
				sorted_aspects[aspect[0]] = aspect[1].sort
			end
		end

		aspects = sorted_aspects


		@results = {"error" => nil}
		@categories = category_hash
		@aspects = aspects
		@aspect_names = aspects.keys
		@items = items
		@selected_categories = []
		if params["category"] != nil then
			@selected_categories = Category.where("title LIKE ?", "#{params["category"]}%")
		else
			@selected_categories = []
		end
		@cart = nil
		if current_user != nil then
			@cart = Cart.where("user_id = ? AND purchased = 0", current_user.id).first
		end

		puts "selected category is #{@selected_categories}"
	end

	def aspects_search
		search_aspects = params["aspects"]
		search_values = params["values"]
		ids = params["ids"]

		if search_aspects != nil then
			if search_aspects.size != search_values.size then
				puts "search aspects is #{search_aspects.size} and search values is #{search_values.size}"
				@results = {"error" => "Aspect parameter must be the same as value parameter"}
				return
			end
		end

		aspects_hash = {}
		search_aspect_names = []
		if search_values != nil then
			search_aspect_names = search_aspects & search_aspects
			(0..search_values.size-1).each do |i|
				if aspects_hash[search_aspects[i]] != nil then
					aspects_hash[search_aspects[i]] << search_values[i]
				else
					aspects_hash[search_aspects[i]] = []
					aspects_hash[search_aspects[i]] << search_values[i]
				end
			end
		end

		items = []
		ids.each do |id|
			items << Item.find(id)
		end

		search_aspect_names.each do |aspect_name|
			possible_items = []
			aspects_hash[aspect_name].each do |value|
				Aspect.where("name = ? AND value = ?", aspect_name, value).each do |aspect|
					possible_items << aspect.item
				end
			end

			items = items & possible_items
		end

		if items[0] == nil then
			render json: {"items" => [], "aspects" => {}}
			return
		end


		aspects = {}
		items.each do |item|
			item.aspects.each do |aspect|
				if aspects[aspect.name] == nil then
					aspects[aspect.name] = [aspect.value]
				else
					if !aspects[aspect.name].include? aspect.value then
						aspects[aspect.name] << aspect.value
						aspects[aspect.name].uniq!
					end
				end
			end
		end

		aspects.delete_if{ |k,v| v.size < 2}

		sorted_aspects = {}
		aspects.sort.each do |aspect|
			if aspect[0] == "Brand" then
				sorted_aspects[aspect[0]] = aspect[1].sort
			end
		end
		aspects.sort.each do |aspect|
			if aspect[0] != "Brand" then
				sorted_aspects[aspect[0]] = aspect[1].sort
			end
		end

		aspects = sorted_aspects

		item_id = []
		items.each do |item|
			item_id << item.id
		end

		render json: {"items" => item_id, "aspects" => aspects}
	end

	def category
		if params["category"] == nil then
			@category = nil
			return
		end

		@categories = []
		Category.all.each do |category|
			if /Clothing, Shoes & Accessories:#{params["category"]}/.match category.title != nil then
				@categories <<  category
			end
		end
	end

	def sort
		items = []
		Item.where("purchased = 0").each do |item|
			items << item
		end
		if params["sort_by"] != nil then
			if params["sort_by"] == "1" then
				items.sort! { |x,y| x.views <=> y.views }
			elsif params["sort_by"] == "2" then
				items.sort! { |x,y| x.created_at <=> y.created_at}
			elsif params["sort_by"] == "4" then
				items.sort! { |x,y| y.price <=> x.price }
			elsif params["sort_by"] == "3" then
				items.sort! { |x,y| x.price <=> y.price }
			end	
		end

		item_ids = []
		items.each do |item|
			item_ids << item.id
		end

		render json: {"items" => item_ids}
	end

	def brands_search
		aspects = []
		a = Aspect.where("name = 'Brand' AND value LIKE ?", "#{params["q"]}%")
		if a == nil then
			render json: {"error" => "No Results", "aspects" => []}
			return
		end

		a.each do |aspect|
			aspects << aspect.value
		end

		render json: {"error" => nil, "aspects" => aspects}
	end
end
