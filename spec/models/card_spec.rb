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

require 'spec_helper'

describe Card do
  let(:info_to_create_card) do
    {
      :card_type => Card::TYPES[:visa_vale],
      :number => Enum::CardNumber::VISA_VALE_VALID_NUMBER,
      :last_charged_at => '2013-01-26',
      :last_charge_amount => 220.00,
      :next_charge => '2013-02-26',
      :next_charge_amount => 0.00,
      :available_balance => 178.99,
      :transactions_hash => "1a" * 20,
      :transactions => [
        {
          :date => '2013-01-31',
          :description => 'RESTAURANTE TASTY',
          :amount => 16.77,
        },
        {
          :date => '2013-01-30',
          :description => 'GRUPO GFB',
          :amount => 11.57,
        },
        {
          :date => '2013-09-06',
          :description => 'THIANE ADM RESTAURANTE',
          :amount => 18.20,
        },
        {
          :date => '2013-09-05',
          :description => 'VERDE SALADAS E SUCOS',
          :amount => 10.90,
        }
      ]
    }
  end

  let(:info_to_update_card) do
    {
      :card_type => Card::TYPES[:visa_vale],
      :number => Enum::CardNumber::VISA_VALE_VALID_NUMBER,
      :last_charged_at => '2013-08-26',
      :last_charge_amount => 260.00,
      :next_charge => '2013-08-27',
      :next_charge_amount => 0.00,
      :available_balance => 110.99,
      :transactions_hash => "2b" * 20,
      :transactions => [
        {
          :date => '2013-09-08',
          :description => 'LENHA NO FOGAO',
          :amount => 15.30,
        },
        {
          :date => '2013-09-07',
          :description => 'NONO',
          :amount => 11.60,
        },
        {
          :date => '2013-09-06',
          :description => 'THIANE ADM RESTAURANTE',
          :amount => 18.20,
        },
        {
          :date => '2013-09-05',
          :description => 'VERDE SALADAS E SUCOS',
          :amount => 10.90,
        },
        {
          :date => '2013-01-31',
          :description => 'RESTAURANTE TASTY',
          :amount => 16.77,
        },
        {
          :date => '2013-01-30',
          :description => 'GRUPO GFB',
          :amount => 11.57,
        },
      ]
    }
  end

  describe "transaction associations" do
    before(:each) do
      @card = Card.new(
        card_type: Card::TYPES[:visa_vale],
        number: '1234567890123456',
        available_balance: 223.25,
        last_charged_at: Date.parse('26/01/2013'),
        last_charge_amount: 220.00,
        next_charge: Date.parse('26/02/2013'),
        next_charge_amount: 260.00,
        transactions_hash: "1a" * 20,
      )
    end

    before { @card.save }
    let!(:older_transaction) do 
      FactoryGirl.create(:card_transaction, card: @card, date: 1.day.ago, created_at: 1.day.ago)
    end
    let!(:newer_transaction) do
      FactoryGirl.create(:card_transaction, card: @card, date: 1.day.ago, created_at: 1.hour.ago)
    end

    it "should have the right transactions in the right order" do
      @card.transactions.should == [newer_transaction, older_transaction]
    end
  end

  describe "persisting methods" do

    let(:card) { Card.create_with_transactions(info_to_create_card) }

    it "should create card with transactions" do
      card.card_type.should == Card::TYPES[:visa_vale]
      card.number.should == Enum::CardNumber::VISA_VALE_VALID_NUMBER
      card.transactions.count.should == 4

      Card.count.should == 1
      CardTransaction.count.should == 4
    end

    it "should update card with transactions" do
      card.update_with_transactions!(info_to_update_card)

      saved_card = Card.find(1)
      info_to_update_card.each do |key, expected_value|
        unless key == :transactions
          begin
            expected_value = Date.parse(expected_value)
          rescue
            # do nothing. expected_value is not a date.
          end

          expected_value.should == card[key]
        end
      end

      Card.count.should == 1

      card.transactions.count.should == 6
      CardTransaction.count.should == 6
    end

    it "should do nothing when transactions_hash is the same" do
      card.update_with_transactions!(info_to_create_card)

      info_to_create_card.each do |key, expected_value|
        unless key == :transactions
          begin
            expected_value = Date.parse(expected_value)
          rescue
            # do nothing. expected_value is not a date.
          end

          expected_value.should == card[key]
        end
      end

      Card.count.should == 1

      card.transactions.count.should == info_to_create_card[:transactions].count
      CardTransaction.count.should == info_to_create_card[:transactions].count
    end
  end

  describe "validation" do
    it "should raise InvalidCardTypeException exception" do
      expect { Card.validate_type 'invalid_card' }.to raise_error(Exceptions::InvalidCardTypeException)
      expect { Card.validate_number_format_by_type 1234, 'invalid-card' }.to raise_error(Exceptions::InvalidCardTypeException)
    end

    describe "number by type" do
      it "should raise InvalidCardNumberException exception for invalid #{Card::TYPES[:visa_vale]} number" do      
        expect { Card.validate_number_format_by_type 1234, Card::TYPES[:visa_vale] }.to raise_error(Exceptions::InvalidCardNumberException)
      end
    end
  end
end
