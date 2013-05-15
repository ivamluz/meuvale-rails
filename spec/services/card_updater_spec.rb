require 'spec_helper'
require 'spec_helper'

describe CardUpdater do
  describe "cards updating" do
    it "should update only cards updated before a given date" do
      without_timestamping_of Card do
        @newer_card = FactoryGirl.create(:card)

        @older_card = FactoryGirl.create(:card)        
        @older_card.number = Enum::CardNumber::VISA_VALE_VALID_NUMBER
        @older_card.created_at = '2013-04-10'
        @older_card.updated_at = @older_card.created_at
        @older_card.save
      end

      updater_service = CardUpdater.new(Fetchers::VisaValeFetcher.new(Mock::Connector.new))
      
      updater_service.update_all_updated_before(@older_card.updated_at + 1.day).should be 1

      @older_card.transactions.count.should > 0
      @newer_card.transactions.count.should be 0
    end
  end
end