require 'spec_helper'

describe "Cards controller", :type => :controller do
  render_views

  let(:date_regex) { /^201[0-9]-(0[1-9]|1[12])-(0[1-9]|[12][0-9]|3[01])$/ }
  let(:optional_date_regex) { /^(201[0-9]-(0[1-9]|1[12])-(0[1-9]|[12][0-9]|3[01]))?$/ }
  let(:amount_regex) { /[0-9]+\.[0-9]{1,2}/ }

  shared_examples 'a valid response' do
    describe 'json' do
      it 'should be valid' do
        response.content_type.should == "application/json"        

        json = JSON.parse(response.body)
        json.should_not be_nil

        json.should_not include('id')

        json.should include('card_type')
        json['card_type'].class.should == String

        json.should include('number')

        json.should include('available_balance')
        json['available_balance'].should match amount_regex

        json.should include('last_charged_at')        
        json['last_charged_at'].to_date.class.should == Date
        json['last_charged_at'].should match date_regex

        json.should include('last_charge_amount')
        json['last_charge_amount'].should match amount_regex

        json.should include('next_charge')
        json['next_charge'].to_s.should match optional_date_regex

        json.should include('next_charge_amount')
        json['next_charge_amount'].should match amount_regex

        json.should include('transactions')
        json['transactions'].class.should == Array

        json['transactions'].each_with_index do |transaction, i|
          # Check is sorted by date, descending
          if i > 0
            transaction['date'].should be >= json['transactions'][i - 1]['date']
          end


          transaction.should_not include('id')

          transaction['description'].should_not be_nil
          transaction['date'].to_s.should match date_regex
          transaction['amount'].should match amount_regex
        end
      end
    end
  end

  shared_examples 'visa vale card' do
    describe 'json' do
      it_behaves_like "a valid response"

      let(:json) { JSON.parse(response.body) }

      it "has right number" do          
        json['number'].should == Enum::CardNumber::VISA_VALE_VALID_NUMBER
      end

      it "has right type" do
        json['card_type'].should == Card::TYPES[:visa_vale]
      end
    end
  end

  describe "visa vale" do
    describe "get with valid card number" do
      before do
        card = FactoryGirl.create(:card)
        card.number = Enum::CardNumber::VISA_VALE_VALID_NUMBER
        card.save

        FactoryGirl.create(:card_transaction, card: card)
        FactoryGirl.create(:card_transaction, card: card)
        FactoryGirl.create(:card_transaction, card: card)
      end

      it_behaves_like "visa vale card" do
        let(:response) { visit "cards/#{Card::TYPES[:visa_vale]}/#{Enum::CardNumber::VISA_VALE_VALID_NUMBER}.json" }

        it "http code should be 200" do
          response.response_code.should == 200
        end
      end
    end

    describe "invalid card number" do
      it "should return a 404 page" do
        visit "cards/#{Card::TYPES[:visa_vale]}/#{Enum::CardNumber::VISA_VALE_INVALID_NUMBER}.json"

        response.response_code.should == 404
      end
    end

    describe "invalid card number format" do
      it "should return a 404 page" do
        expect { visit "cards/#{Card::TYPES[:visa_vale]}/abc.json" }.to raise_error(ActionController::RoutingError)
        expect { visit "cards/#{Card::TYPES[:visa_vale]}/123.json" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe "card creation" do
      # describe "when card doesn't exist" do
      #   it_behaves_like "visa vale card" do
      #     let(:response) do 
      #       post 'cards', { :type => Card::TYPES[:visa_vale], :number => Enum::CardNumber::VISA_VALE_VALID_NUMBER },
      #                     { 'HTTP_CONTENT_TYPE' => "application/json", 'HTTP_ACCEPT' => "application/json" } 
      #     end

      #     it "when card is created" do
      #       response.response_code.should == 201
      #     end
      #   end
      # end
      describe "when card doesn't exist" do
        it "should create a card" do
          post 'cards', { :type => Card::TYPES[:visa_vale], :number => Enum::CardNumber::VISA_VALE_VALID_NUMBER },
                        { 'HTTP_CONTENT_TYPE' => "application/json", 'HTTP_ACCEPT' => "application/json" } 

          response.response_code.should == 201

          Card.count.should == 1
          CardTransaction.count.should > 0

          card = Card.first

          card.card_type.should == Card::TYPES[:visa_vale]
          card.number.should == Enum::CardNumber::VISA_VALE_VALID_NUMBER
          card.transactions.count.should > 0
        end
      end

      describe "when card exists" do
        before do
          post 'cards', { :type => Card::TYPES[:visa_vale], :number => Enum::CardNumber::VISA_VALE_VALID_NUMBER },
                        { 'HTTP_CONTENT_TYPE' => "application/json", 'HTTP_ACCEPT' => "application/json" }
        end

        it "should not create a new card" do
          post 'cards', { :type => Card::TYPES[:visa_vale], :number => Enum::CardNumber::VISA_VALE_VALID_NUMBER },
                        { 'HTTP_CONTENT_TYPE' => "application/json", 'HTTP_ACCEPT' => "application/json" }

          Card.count.should == 1
        end

        it "should return the right http code" do
          post 'cards', { :type => Card::TYPES[:visa_vale], :number => Enum::CardNumber::VISA_VALE_VALID_NUMBER },
                        { 'HTTP_CONTENT_TYPE' => "application/json", 'HTTP_ACCEPT' => "application/json" }
          response.response_code.should == 200          
        end

        it "should return a valid json object" do
          post 'cards', { :type => Card::TYPES[:visa_vale], :number => Enum::CardNumber::VISA_VALE_VALID_NUMBER },
                        { 'HTTP_CONTENT_TYPE' => "application/json", 'HTTP_ACCEPT' => "application/json" }

          response.content_type.should == "application/json"        

          json = JSON.parse(response.body)
          json.should_not be_nil

          json.should include('card_type')
          json['card_type'].class.should == String

          json.should include('number')

          json.should include('available_balance')
          json['available_balance'].should match amount_regex

          json.should include('last_charged_at')        
          json['last_charged_at'].to_date.class.should == Date
          json['last_charged_at'].should match date_regex

          json.should include('last_charge_amount')
          json['last_charge_amount'].should match amount_regex

          json.should include('next_charge')
          json['next_charge'].to_s.should match optional_date_regex

          json.should include('next_charge_amount')
          json['next_charge_amount'].should match amount_regex

          json.should include('transactions')
          json['transactions'].class.should == Array

          json['transactions'].each do |transaction|
            transaction['description'].should_not be_nil
            transaction['date'].to_s.should match date_regex
            transaction['amount'].should match amount_regex
          end
        end
      end

      describe "when card number is invalid" do
        it "request should be invalid" do
          post 'cards', { :type => Card::TYPES[:visa_vale], :number => Enum::CardNumber::VISA_VALE_INVALID_NUMBER },
                        { 'HTTP_CONTENT_TYPE' => "application/json", 'HTTP_ACCEPT' => "application/json" }
          response.response_code.should == 400

          post 'cards', { :type => Card::TYPES[:visa_vale], :number => 'foo' },
                        { 'HTTP_CONTENT_TYPE' => "application/json", 'HTTP_ACCEPT' => "application/json" }
          response.response_code.should == 400
        end
      end
    end    
  end

  describe "when card type is invalid" do
    it "should not be found" do
      visit "cards/invalid_card/#{Enum::CardNumber::VISA_VALE_VALID_NUMBER}.json"

      response.response_code.should == 404
    end

    it "post should be bad request" do
      post 'cards', { :type => 'invalid-card', :number => 1234 },
                    { 'HTTP_CONTENT_TYPE' => "application/json", 'HTTP_ACCEPT' => "application/json" }

      response.response_code.should == 400
    end
  end
end