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

require 'test_helper'

class CardTransactionTest < ActiveSupport::TestCase
  def setup
    @card = Card.create(
      card_type: Card::TYPES[:visa_vale],
      number: '1234567890123456'
    )

    @transaction = @card.transactions.build(
      date: Date.parse('26/01/2013'),
      description: 'Thiane',
      amount: 23.25
    )

    # @transaction = CardTransaction.new
    # @transaction.date = Date.parse('26/01/2013')
    # @transaction.description = 'Thiane'
    # @transaction.amount = 23.25

    @original_transaction = Marshal::load(Marshal.dump(@transaction))
  end

  test "transaction exposes expected attributes" do
    assert(@transaction.respond_to? :date)
    assert(@transaction.respond_to? :description)
    assert(@transaction.respond_to? :amount)
    assert(@transaction.respond_to? :card)
    assert(@transaction.respond_to? :card_id)
  end

  test "non nullable fields dont accept empty values" do
    [:date, :description, :amount].each do |field|
      ['', nil,].each do |empty_value|
        @transaction[field] = empty_value
        assert(!@transaction.valid?, "#{field} field should not accept empty values")
        @transaction[field] = @original_transaction[field]
      end
    end
  end

  test "field max lengths validation" do
    @transaction.description = ('a' * 31)
    
    assert(!@transaction.valid?)
  end

  test "all validations with valid values" do
    assert(@transaction.valid?)
  end

test "invalid date formats validation" do
    [:date].each do |date_field|
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
        @transaction[date_field] = invalid_date
        assert(!@transaction.valid?, "#{invalid_date} date validation should fail for field #{date_field.to_s}")
        @transaction[date_field] = @original_transaction[date_field]
      end
    end
  end

  test "valid date formats validation" do
    [:date].each do |date_field|
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
        @transaction[date_field] = valid_date
        assert(@transaction.valid?, "#{valid_date} date validation should not fail for field #{date_field.to_s}")
        @transaction[date_field] = @original_transaction[date_field]
      end
    end
  end

  test "amount fields with valid format" do
    [:amount].each do |amount_field|
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
        @transaction[amount_field] = valid_value
        assert(@transaction.valid?, "#{valid_value} amount validation should not fail")
        @transaction[amount_field] = @original_transaction[amount_field]
      end
    end
  end

  test "amount fields with invalid format" do
    [:amount].each do |amount_field|
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
        @transaction[amount_field] = invalid_value
        assert(!@transaction.valid?, "#{amount_field} amount validation should fail")
        @transaction[amount_field] = @original_transaction[amount_field]
      end
    end
  end

  test "amount fields dont accept negative values" do
    [:amount].each do |amount_field|
      @transaction[amount_field] = -10
      assert(!@transaction.valid?, "#{amount_field} field should not accept negative values")
      @transaction[amount_field] = @original_transaction[amount_field]
    end
  end

  test "amount fields dont accept 0" do
    [:amount].each do |amount_field|
      zero_values = [
        0,
        0.0,
        0.00,
      ]
      zero_values.each do |zero_value|
        @transaction[amount_field] = zero_value
        assert(!@transaction.valid?, "#{amount_field} amount validation should fail")
        @transaction[amount_field] = @original_transaction[amount_field]
      end
    end
  end

  test "should not allow access to card_id" do
    assert_raise(ActiveModel::MassAssignmentSecurity::Error) do
      CardTransaction.new(card_id: @card.id)
    end
  end

  test "transaction belongs to right card" do
    assert(@transaction.card == @card)
  end

  test "card id is mandatory" do
    transaction = CardTransaction.new(
      date: Time.now,
      description: 'Thiane',
      amount: 22.22
    )

    assert(!transaction.valid?)
  end

  test "transaction relationship with card" do
    assert(@transaction.card == @card)
  end
end
