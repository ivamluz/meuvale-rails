require 'spec_helper'

describe Card do  
  describe "transaction associations" do

    before(:each) do
      @card = Card.create(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    before { @card.save }
    let!(:older_transaction) do 
      FactoryGirl.create(:transaction, card: @card, date: 1.day.ago, created_at: 1.day.ago)
    end
    let!(:newer_transaction) do
      FactoryGirl.create(:transaction, card: @card, date: 1.day.ago, created_at: 1.hour.ago)
    end

    it "should have the right transactions in the right order" do
      @card.transactions.should == [newer_transaction, older_transaction]
    end
  end
end