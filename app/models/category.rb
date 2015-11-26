class Category < ActiveRecord::Base
	has_many :aspects
	has_many :items
end
