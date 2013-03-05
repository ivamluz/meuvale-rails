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

require 'test_helper'

class CardTest < ActiveSupport::TestCase
  def setup
    @card = Card.new
    @card.card_type = 'visa_vale'
    @card.number = '1234567890'
    @card.last_charged_at = Date.parse('26/01/2013')
    @card.next_charge = Date.parse('26/02/2013')
    @card.available_balance = 223.25
    @card.last_charge_amount = 220.00
    @card.next_charge_amount = 260.00

    @original_card = Marshal::load(Marshal.dump(@card))
  end

  test "card exposes expected attributes" do
    assert(@card.respond_to? :card_type)
    assert(@card.respond_to? :number)
    assert(@card.respond_to? :available_balance)
    assert(@card.respond_to? :last_charged_at)
    assert(@card.respond_to? :last_charge_amount)
    assert(@card.respond_to? :next_charge)
    assert(@card.respond_to? :next_charge_amount)
  end

  test "non nullable fields dont accept empty values" do
    [:card_type, :number,].each do |field|
      ['', nil,].each do |empty_value|
        @card[field] = empty_value
        @card.save
        assert(!@card.valid?)
        @card[field] = @original_card[field]
      end
    end
  end

  test "nullable fields accept empty values" do
    nullable_fields = [:last_charged_at, :next_charge, :available_balance, :last_charge_amount, :next_charge_amount]
    nullable_fields.each do |field|
      ['', nil,].each do |empty_value|
        @card[field] = empty_value
        @card.save
        assert(@card.valid?)
      end
    end
  end

  test "fields limits are respected" do

  end

  test "card number format validation" do
  end

  test "card has a valid type" do
  end

  test "date fields validation" do
  end

  test "amount fields format validation" do
  end

  test "amount fields dont accept negative values" do
  end
end
