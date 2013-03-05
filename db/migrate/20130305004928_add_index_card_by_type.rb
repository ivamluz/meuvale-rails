class AddIndexCardByType < ActiveRecord::Migration
  def change
    add_index :cards, [:card_type, :number], :unique => true
  end
end
