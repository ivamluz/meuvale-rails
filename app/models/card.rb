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
  TYPES = {
    :visa_vale => 'visa_vale'
  }

  attr_accessible :card_type, :number,
                  :last_charged_at, :available_balance, 
                  :last_charge_amount, :next_charge_amount

  validates :card_type, 
            presence: true, length: { maximum: 20 }, inclusion: { in: TYPES.values }
  validates :number, presence: true, length: { maximum: 30 }, format: { with: /^[0-9]{16}$/ }

  validates :available_balance, :last_charge_amount, :next_charge_amount,
            numericality: { greater_than_or_equal_to: 0 },
            format: { with: /^\d+(\.\d{1,2})?$/ },
            allow_blank: true

  validates_date :last_charged_at, :next_charge, allow_nil: true
end
