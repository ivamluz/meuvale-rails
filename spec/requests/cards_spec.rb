require 'spec_helper'

describe "Cards controller", :type => :controller do
  render_views

  describe "visa vale" do

    describe "valid card number" do
      it "should return a valid json response" do
        visit "cards/#{Enum::CardNumber::VISA_VALE_VALID_NUMBER}.json"

        response.content_type.should == "application/json"

        json = JSON.parse(response.body)
        json.should_not be_nil

        json.should include('type')
        json['type'].should == 'visa_vale'

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
        visit "cards/#{Enum::CardNumber::VISA_VALE_INVALID_NUMBER}.json"

        response.response_code.should == 404
      end
    end
  end
end