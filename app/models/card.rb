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
#  transactions_hash  :string(40)       default(""), not null
#

class Card < ActiveRecord::Base
  TYPES = {
    :visa_vale => 'visa-vale'
  }

  NUMBER_VALIDATION_PATTERNS = {
    TYPES[:visa_vale] => /^\d{16}$/
  }

  has_many :transactions, :class_name => "CardTransaction"

  attr_accessible :card_type, :number, :available_balance,
                  :last_charged_at, :last_charge_amount,
                  :next_charge, :next_charge_amount,
                  :transactions_hash

  validates :card_type, 
            presence: true, length: { maximum: 20 }, inclusion: { in: TYPES.values }
  validates :number, presence: true, length: { maximum: 30 }, format: { with: /^[0-9]{16}$/ }

  validates :available_balance, :last_charge_amount, :next_charge_amount,
            numericality: { greater_than_or_equal_to: 0 },
            format: { with: /^\d+(\.\d{1,2})?$/ },
            allow_blank: true            

  validates_date :last_charged_at, :next_charge, allow_nil: true

  validates :transactions_hash, format: { with: /^[0-9a-f]{40}$/ }

  def self.validate_type(type)
    if !TYPES.has_value? type
      raise Exceptions::InvalidCardTypeException
    end
  end

  def self.validate_number_format_by_type(number, type)
    validate_type(type)

    if !NUMBER_VALIDATION_PATTERNS[type].match number.to_s
      raise Exceptions::InvalidCardNumberException
    end
  end

  def self.create_with_transactions(card_info)
    card = nil
    ActiveRecord::Base.transaction do
      local_card_info = Marshal::load(Marshal.dump(card_info))
      local_card_info.delete(:transactions)
      card = Card.create(local_card_info)

      card_info[:transactions].each do |transaction|
        card.transactions.create(transaction)
      end
    end

    card
  end

  def update_with_transactions!(card_info)
    unless self.transactions_hash == card_info[:transactions_hash] or
           card_info[:transactions].nil?
      ActiveRecord::Base.transaction do
        local_card_info = Marshal::load(Marshal.dump(card_info))
        local_card_info.delete(:transactions)
        self.update_attributes(local_card_info)

        card_info[:transactions].each do |transaction|
          # to avoid duplicated transactions, existing transactions with
          # the same date of the transaction being processed are deleted
          CardTransaction.delete_all(card_id: self.id, date: transaction[:date])
          self.transactions.create(transaction)
        end
      end
    end

    self
  end

  def self.updated_before(date)
    Card.where("updated_at < :date", { :date => date } )
  end
end
