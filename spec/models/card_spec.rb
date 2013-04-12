require 'spec_helper'

describe Card do  
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