class Wishlist < ActiveRecord::Base
	belongs_to :user
	has_and_belongs_to_many :items, :through => :items_wishlists
end
