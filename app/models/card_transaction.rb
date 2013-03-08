# == Schema Information
#
# Table name: card_transactions
#
#  id          :integer          not null, primary key
#  date        :date             not null
#  description :string(30)       not null
#  amount      :decimal(6, 2)    not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CardTransaction < ActiveRecord::Base
  belongs_to :card

  attr_accessible :date, :description, :amount

  validates :date, :description, :amount,
            presence: true

  validates :description,
            length: { maximum: 30 }

  validates :amount,
            numericality: { greater_than: 0 },
            format: { with: /^\d+(\.\d{1,2})?$/ }

  validates_date :date
end
