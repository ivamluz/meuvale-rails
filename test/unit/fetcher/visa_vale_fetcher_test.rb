require 'test_helper'

# TODO: Implement logic to test charge dates (when next charge is on next year)

class VisaValeFetcherTest < ActiveSupport::TestCase
  VALIDATION_PATTERN = {
    :amount_regex        => /^[0-9]{1,4}\.[0-9]{2}$/,
    :card_number_regex   => /^[0-9]{16}$/,
    :date_regex          => /^[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}$/,
    :optional_date_regex => /^([0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4})?$/,
  }

  def setup
    @fetcher = Fetchers::VisaValeFetcher.new(Mock::Connector.new)
  end

  test "exception is raised if invalid connector is given" do
    assert_raise(NoMethodError) { Fetchers::VisaValeFetcher.new(Object.new) }
  end

  test "exception is raised when invalid card is fetched" do
    exception = assert_raise(Exceptions::InvalidCardNumberException) do
      @fetcher.fetch_card(Enum::CardNumber::VISA_VALE_INVALID_NUMBER)
    end
  end

  test "fetch valid card with transactions" do
    card = @fetcher.fetch_card(Enum::CardNumber::VISA_VALE_VALID_NUMBER);

    assert_match(VALIDATION_PATTERN[:card_number_regex], card[:number]);
    assert_match(VALIDATION_PATTERN[:date_regex], card[:last_charged_at]);
    assert_match(VALIDATION_PATTERN[:amount_regex], card[:last_charge_amount]);
    assert_match(VALIDATION_PATTERN[:optional_date_regex], card[:next_charge]);
    assert_match(VALIDATION_PATTERN[:amount_regex], card[:next_charge_amount]);
    assert_match(VALIDATION_PATTERN[:amount_regex], card[:available_balance]);

    card[:transactions].each do |transaction|
      assert_match(VALIDATION_PATTERN[:date_regex], transaction[:date]);
      assert(!transaction[:description].empty?);
      assert_match(VALIDATION_PATTERN[:amount_regex], transaction[:amount]);
    end
  end
end