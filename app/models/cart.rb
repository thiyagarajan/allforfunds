class Cart < ActiveRecord::Base
	belongs_to :user
	has_and_belongs_to_many :items, :through => :items_carts

	def total
		total = 0.0
		items.each do |item|
			total += item.price
		end

		total
	end

	def shipping_cost


		total = 0.0
		items.each do |item|
			total += item.shipping_price
		end
		if self.user.shipping_country != nil and self.user.shipping_country != "US" then
			total += 35.00
		end

		total
	end

	def grand_total
		((total + shipping_cost) * (1 + Admin.first.tax)).round(2)
	end
end
