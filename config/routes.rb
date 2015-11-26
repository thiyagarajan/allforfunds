Rails.application.routes.draw do
  devise_for :users
  get '/search' => 'shop#search'
  get "/cart" => "cart#show"
  post '/cart/add' => 'cart#add_to_cart'
  post '/cart/remove' => 'cart#remove_from_cart'
  get '/wishlist' => "wishlist#show"
  post '/wishlist/add' => 'wishlist#add'
  post '/wishlist/remove' => 'wishlist#remove'
  get '/products' => 'items#index'
  get '/view/:name' => 'items#show'
  get '/' => "shop#index"
  get '/shop' => "shop#shop"
  post '/shop' => "shop#shop"
  post '/shop/aspect' => "shop#aspects_search"
  post '/shop/sort' => "shop#sort"
  resources :items
  resources :cart
  resources :user
  get '/checkout' => "checkout#shipping"
  get '/checkout/billing' => "checkout#billing"
  get '/checkout/payment' => "checkout#payment"
  get '/confirm' => "checkout#payment"
  post '/checkout/billing' => "checkout#billing"
  post '/checkout/payment' => "checkout#payment"
  post '/checkout/same-address' => "checkout#same"
  post '/confirm' => "checkout#confirm"
  post '/purchase' => "checkout#purchase"
  get '/paypal/charge' => "checkout#pay_paypal"

  get '/category' => "shop#category"
  get '/returns' => "shop#returns"
  get '/sell' => "shop#sell"
  get '/terms' => "shop#terms"
  get '/authenticity' => "shop#authenticity"
  get '/about' => "shop#about"
  get '/privacy' => "shop#privacy"
  get '/about' => "shop#about"
  get '/nav' => "shop#about"
  get '/contact' => "shop#contact"
  get '/shopbyprice' => "shop#shopbyprice"

  get "/account" => "user#account"
  get "/account/orders" => "user#orders"
  get "/account/address" => "user#address"
  get "/account/information" => "user#information"

  post "/contact" => "shop#send_contact_email"
  post "/sell/sign_up" => "shop#sell_sign_up"

  post "/brands/search" => "shop#brands_search"


  as :user do 
  	get "/login" => "devise/sessions#new"
  end
end
