require 'spec_helper'

describe "Cards controller", :type => :controller do
  render_views

  describe "visa vale" do

    describe "valid card number" do
      it "should return a valid json response" do
        visit "cards/#{Card::TYPES[:visa_vale]}/#{Enum::CardNumber::VISA_VALE_VALID_NUMBER}.json"

        response.content_type.should == "application/json"
        response.response_code.should == 200

        json = JSON.parse(response.body)
        json.should_not be_nil

        json.should include('type')
        json['type'].should == Card::TYPES[:visa_vale]

        json.should include('number')
        json['number'].should == Enum::CardNumber::VISA_VALE_VALID_NUMBER

        json.should include('available_balance')
        json['available_balance'].class.should == Float

        json.should include('last_charged_at')        
        json['last_charged_at'].to_date.class.should == Date
        json['last_charged_at'].should match /^201[0-9]-(0[1-9]|1[12])-(0[1-9]|[12][0-9]|3[01])$/

        json.should include('last_charge_amount')
        json['last_charge_amount'].class.should == Float
        json['last_charge_amount'].should > 0

        json.should include('next_charge')
        json['next_charge'].should match /^(201[0-9]-(0[1-9]|1[12])-(0[1-9]|[12][0-9]|3[01]))?$/

        json.should include('next_charge_amount')
        json['next_charge_amount'].class.should == Float
        json['next_charge_amount'].should >= 0

        json.should include('transactions')
        json['transactions'].class.should == Array
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
      # it "should create a card" do
      #   response.content_type.should == "application/json"
      #   response.response_code.should == 200

      #   json = JSON.parse(response.body)
      #   json.should_not be_nil
      # end

      it "invalid card number should return error 400" do
        post 'cards', { :type => Card::TYPES[:visa_vale], :number => Enum::CardNumber::VISA_VALE_INVALID_NUMBER },
                      { 'HTTP_CONTENT_TYPE' => "application/json", 'HTTP_ACCEPT' => "application/json" }

        response.response_code.should == 400
      end
    end    
  end

  describe "invalid card type" do
    it "get should return a 404 page" do
      visit "cards/invalid_card/#{Enum::CardNumber::VISA_VALE_VALID_NUMBER}.json"

      response.response_code.should == 404
    end

    it "creation should return error 400" do
      post 'cards', { :type => 'invalid-card', :number => 1234 },
                    { 'HTTP_CONTENT_TYPE' => "application/json", 'HTTP_ACCEPT' => "application/json" }

      response.response_code.should == 400
    end
  end
end