class Item < ActiveRecord::Base
  has_many :aspects
  has_many :photos
  belongs_to :category
  has_and_belongs_to_many :carts

  def url
    # "/view/#{title.gsub("%","%25").gsub("+","%2F").gsub(" ","+" ).gsub("/","%27").gsub("(", "%28").gsub(")", "%29").gsub(".", "%2E")}"
    "/view/#{title.gsub("%", "%25").gsub("+", "%2F").gsub(" ", "+").gsub("/", "*").gsub("(", "%28").gsub(")", "%29").gsub(".", "%2E")}"
  end
end
