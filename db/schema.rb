# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141130184302) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: true do |t|
    t.decimal "tax", precision: 20, scale: 10, default: 0.08
  end

  create_table "aspects", force: true do |t|
    t.string   "name",        null: false
    t.string   "value"
    t.integer  "category_id"
    t.integer  "item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carts", force: true do |t|
    t.integer  "user_id"
    t.integer  "purchased",  default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carts_items", force: true do |t|
    t.integer "cart_id"
    t.integer "item_id"
  end

  create_table "categories", force: true do |t|
    t.string   "eId",        null: false
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", force: true do |t|
    t.string   "eId",                                                     null: false
    t.string   "title",                                                   null: false
    t.decimal  "price",          precision: 20, scale: 2,                 null: false
    t.string   "url"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "purchased",                               default: false
    t.integer  "views",                                   default: 0
    t.decimal  "shipping_price", precision: 20, scale: 2, default: 0.0
  end

  create_table "items_wishlists", force: true do |t|
    t.integer "wishlist_id"
    t.integer "item_id"
  end

  create_table "orders", force: true do |t|
    t.integer  "cart_id"
    t.integer  "user_id"
    t.string   "shipping_address"
    t.string   "shipping_address_2"
    t.string   "shipping_state"
    t.string   "shipping_city"
    t.string   "shipping_country"
    t.string   "shipping_first_name"
    t.string   "shipping_last_name"
    t.string   "shipping_zip_code"
    t.string   "stripe_token"
    t.string   "payment_method"
    t.string   "stripe_id"
    t.string   "paypal_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", force: true do |t|
    t.integer  "item_id"
    t.string   "url",                    null: false
    t.integer  "is_gallery", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                    default: "",    null: false
    t.string   "encrypted_password",       default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "shipping_first_name"
    t.string   "shipping_last_name"
    t.string   "shipping_company"
    t.string   "shipping_address"
    t.string   "shipping_address_2"
    t.string   "shipping_city"
    t.string   "shipping_state"
    t.string   "shipping_zip_code"
    t.string   "shipping_country"
    t.text     "shipping_additional_info"
    t.string   "shipping_phone"
    t.string   "billing_first_name"
    t.string   "billing_last_name"
    t.string   "billing_company"
    t.string   "billing_address"
    t.string   "billing_address_2"
    t.string   "billing_city"
    t.string   "billing_state"
    t.string   "billing_zip_code"
    t.string   "billing_country"
    t.text     "billing_additional_info"
    t.string   "billing_phone"
    t.string   "billing_method"
    t.string   "addtional_comments"
    t.string   "card_number"
    t.string   "card_name"
    t.string   "cvv"
    t.string   "expiration_date"
    t.boolean  "save_card_info",           default: false
    t.string   "stripe_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "wishlists", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
