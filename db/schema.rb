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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130417213421) do

  create_table "card_transactions", :force => true do |t|
    t.integer  "card_id"
    t.date     "date",                                                    :null => false
    t.string   "description", :limit => 30,                               :null => false
    t.decimal  "amount",                    :precision => 6, :scale => 2, :null => false
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
  end

  add_index "card_transactions", ["amount"], :name => "index_card_transactions_on_amount"
  add_index "card_transactions", ["card_id", "date"], :name => "index_card_transactions_on_card_id_and_date"
  add_index "card_transactions", ["description"], :name => "index_card_transactions_on_description"

  create_table "cards", :force => true do |t|
    t.string   "card_type",          :limit => 20,                                               :null => false
    t.string   "number",             :limit => 30,                                               :null => false
    t.date     "last_charged_at"
    t.date     "next_charge"
    t.decimal  "available_balance",                :precision => 6, :scale => 2
    t.decimal  "last_charge_amount",               :precision => 6, :scale => 2
    t.decimal  "next_charge_amount",               :precision => 6, :scale => 2
    t.datetime "created_at",                                                                     :null => false
    t.datetime "updated_at",                                                                     :null => false
    t.string   "transactions_hash",  :limit => 40,                               :default => "", :null => false
  end

  add_index "cards", ["card_type", "number"], :name => "index_cards_on_card_type_and_number", :unique => true

end
