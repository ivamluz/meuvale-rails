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
    @card = Card.new(
      card_type: Card::TYPES[:visa_vale],
      number: '1234567890123456',
      available_balance: 223.25,
      last_charged_at: Date.parse('26/01/2013'),
      last_charge_amount: 220.00,
      next_charge: Date.parse('26/02/2013'),
      next_charge_amount: 260.00,
    )

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
    assert(@card.respond_to? :transactions)
  end

  test "non nullable fields dont accept empty values" do
    [:card_type, :number,].each do |field|
      ['', nil,].each do |empty_value|
        @card[field] = empty_value
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
        assert(@card.valid?)
      end
    end
  end

  test "field max lengths validation" do
    @card.card_type = ('a' * 21)
    @card.number = ('1' * 31).to_i
    
    assert(!@card.valid?)
  end

  test "invalid card number validation" do
    @card.number = '1234'
    assert(!@card.valid?)
  end

  test "all validations with valid values" do
    assert(@card.valid?)
  end

  test "invalid card type validation" do
    @card.card_type = 'bancred'
    assert(!@card.valid?)
  end

  test "invalid date formats validation" do
    [:last_charged_at, :next_charge].each do |date_field|
      invalid_date_formats = [
        '1/26/2013',
        '2/28/2013',
        '2/28',
        '13/13/2013',
        '13/13/13',
        '12/31/2013',
        '2/29/2013',
      ]

      invalid_date_formats.each do |invalid_date|
        @card[date_field] = invalid_date
        assert(!@card.valid?, "#{invalid_date} date validation should fail for field #{date_field.to_s}")
        @card[date_field] = @original_card[date_field]
      end
    end
  end

  test "valid date formats validation" do
    [:last_charged_at, :next_charge].each do |date_field|
      valid_date_formats = [
        '26/1/2013',
        '28/2/2013',
        '13/12/2013',
        '31/12/13',
        '1/1/2013',
        '01/01/2013',
        '01/1/2013',
        '1/01/2013',
        '29/2/2012',
      ]

      valid_date_formats.each do |valid_date|
        @card[date_field] = valid_date
        assert(@card.valid?, "#{valid_date} date validation should not fail for field #{date_field.to_s}")
        @card[date_field] = @original_card[date_field]
      end
    end
  end

  test "amount fields with valid format" do
    [:available_balance, :last_charge_amount, :next_charge_amount].each do |amount_field|
      valid_values = [
        1,
        1.2,
        1.25,
        1.35,
        1.23,
        124.12,
        0.25,
        9999.99,
      ]
      valid_values.each do |valid_value|
        @card[amount_field] = valid_value
        assert(@card.valid?, "#{valid_value} amount validation should not fail")
        @card[amount_field] = @original_card[amount_field]
      end
    end
  end

  test "amount fields with invalid format" do
    [:available_balance, :last_charge_amount, :next_charge_amount].each do |amount_field|
      invalid_values = [
        'a',
        'a.a',
        'a.1',
        '1.a',
        '1.1a',
        'a.01',
        'aa.aa',
        '1a.a1',
        99999.999        
      ]
      invalid_values.each do |invalid_value|
        @card[amount_field] = invalid_value
        assert(!@card.valid?, "#{invalid_value} amount validation should fail")
        @card[amount_field] = @original_card[amount_field]
      end
    end
  end

  test "amount fields dont accept negative values" do
    [:available_balance, :last_charge_amount, :next_charge_amount].each do |amount_field|
      @card[amount_field] = -10
      assert(!@card.valid?)
      @card[amount_field] = @original_card[amount_field]
    end
  end

  test "amount fields accept 0" do
    [:available_balance, :last_charge_amount, :next_charge_amount].each do |amount_field|
      zero_values = [
        0,
        0.0,
        0.00,
      ]
      zero_values.each do |zero_value|
        @card[amount_field] = zero_value
        assert(@card.valid?, "#{zero_value} amount validation should not fail")
        @card[amount_field] = @original_card[amount_field]
      end
    end
  end
end
