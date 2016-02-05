class ItemsController < ApplicationController
  def show_all
    @items = Item.all
  end

  def show
    @item = nil
    if params[:name] == nil then
      @item = Item.find(params[:id])
    else
      @item = Item.where("title = ?", params[:name].gsub("%2E", ".").gsub("%29", ")").gsub("%28", "(").gsub("*", "/").gsub("+", " ").gsub("%2F", "+").gsub("%25", "%") { |match|}).first
      if @item == nil then
        flash.now[:alert] = title
        raise ActionController::RoutingError.new('Not Found')
        flash.now[:alert] = title
      end

      @item.views += 1
      @item.save

      @is_in_cart = false
      @is_in_wishlist = false

      if current_user != nil then
        cart = Cart.where("user_id = ? and purchased = 0", current_user.id).first
        wishlist = Wishlist.where("user_id = ?", current_user.id).first
        if cart != nil then
          unless cart.items == nil then
            if cart.items.include? @item then
              @is_in_cart = true
            end
          end
        end

        if wishlist != nil then
          unless wishlist.items == nil then
            if wishlist.items.include? @item then
              @is_in_wishlist = true
            end
          end
        end
      end

      begin
        @similar_items = []
        possible_items = Item.where("category_id = ?", @item.category.id)
        # possible_items = Item.where("category_id = ? AND id != ?", @item.category.id, @item.id)
        if possible_items.size > 0 then
          @similar_items << possible_items[rand(possible_items.count - 1)]
          if possible_items.size > 1 then
            @similar_items << possible_items[rand(possible_items.count - 1)]
            if possible_items.size > 2 then
              @similar_items << possible_items[rand(possible_items.count - 1)]
            end
          end
        end
        brand_aspects = Aspect.where("name = 'Brand' AND value = ? ",
                                     Aspect.where("item_id = ? AND name = 'Brand'", @item.id).first.value)
        # brand_aspects = Aspect.where("name = 'Brand' AND value = ? AND item_id != ?",
        # 	Aspect.where("item_id = ? AND name = 'Brand'", @item.id).first.value, @item.id)
        if brand_aspects.count > 0 then
          @similar_items << brand_aspects[rand(brand_aspects.count - 1)].item
          @similar_items << brand_aspects[rand(brand_aspects.count - 1)].item
          @similar_items << brand_aspects[rand(brand_aspects.count - 1)].item
        end
        @similar_items.uniq!
        @similar_items.shuffle!
      rescue Exception => e
        puts "Failed to find similar items because #{e.message}. Ignoring..."
        @similar_items = []
      end
    end
  end
end