# == Schema Information
#
# Table name: cards
#
#  id                 :integer          not null, primary key
#  card_type          :string(20)       not null
#  number             :string(30)       not null
#  last_charged_at    :date
#  next_charge        :date
#  available_balance  :decimal(6, 2)
#  last_charge_amount :decimal(6, 2)
#  next_charge_amount :decimal(6, 2)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Card < ActiveRecord::Base
  attr_accessible :card_type, :number,
                  :last_charged_at, :available_balance, 
                  :last_charge_amount, :next_charge_amount

  validates :card_type, :number, presence: true
end
