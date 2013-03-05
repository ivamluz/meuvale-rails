class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string  :card_type, 
                :limit => 20, :null => false
      t.string  :number, 
                :limit => 30, :null => false
      t.date    :last_charged_at, :next_charge
      t.decimal :available_balance, :last_charge_amount, :next_charge_amount, 
                :precision => 6, :scale => 2

      t.timestamps
    end
  end
end
