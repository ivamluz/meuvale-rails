require 'spec_helper'

describe "Cards controller", :type => :controller do
  render_views

  subject { page }

  describe "valid card number" do
    it "should return a valid json response" do
      visit "cards/#{Enum::CardNumber::VISA_VALE_VALID_NUMBER}.json"

      response.content_type.should == "application/json"

      json = JSON.parse(response.body)
      json.should_not be_nil

      json.should include('type')
      json.should include('number')
      json.should include('available_balance')
      json.should include('last_charged_at')
      json.should include('last_charge_amount')
      json.should include('next_charge')
      json.should include('next_charge_amount')
      json.should include('transactions')
    end
  end

  describe "invalid card number" do
    it "should return a 404 page" do
      visit "cards/#{Enum::CardNumber::VISA_VALE_INVALID_NUMBER}.json"

      response.response_code.should == 404
    end
  end
end