class CreateCardTransactions < ActiveRecord::Migration
  def change
    create_table :card_transactions do |t|
      t.integer :card_id
      t.date    :date,
                :null => false
      t.string  :description,
                :limit => 30, :null => false
      t.decimal :amount,
                :precision => 6, :scale => 2,
                :null => false
      t.timestamps
    end

    add_index :card_transactions, [:card_id, :date]
    add_index :card_transactions, [:description]
    add_index :card_transactions, [:amount]
  end
end
