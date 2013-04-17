class AddTransactionsHashToCard < ActiveRecord::Migration
  def change
    add_column :cards, :transactions_hash, 
                       :string, :limit => 40, :null => false, default: ""

    # by-pass rails valition for requiring a default value to create a non null column.                
    change_column :cards, :transactions_hash, 
                          :string, :limit => 40, :null => false
  end
end
