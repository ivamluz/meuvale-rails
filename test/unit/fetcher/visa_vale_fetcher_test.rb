require 'test_helper'

# TODO: Implement logic to test charge dates (when next charge is on next year)

class VisaValeFetcherTest < ActiveSupport::TestCase
  VALIDATION_PATTERN = {
    :card_number_regex   => /^[0-9]{16}$/,
    :date_regex          => /^[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}$/,
    :optional_date_regex => /^([0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4})?$/,
    :amount_regex        => /[0-9]+\.[0-9]{2}/
  }

  def setup
    @fetcher = Fetchers::VisaValeFetcher.new(Mock::Connector.new)
  end

  def assert_card(card)
    assert_match(VALIDATION_PATTERN[:card_number_regex], card[:number])
    assert((card[:last_charged_at].is_a? Date), "last_charged_at should be a valid date.")
    assert_match(VALIDATION_PATTERN[:amount_regex], card[:last_charge_amount])
    assert_match(VALIDATION_PATTERN[:optional_date_regex], card[:next_charge])
    assert_match(VALIDATION_PATTERN[:amount_regex], card[:next_charge_amount])
    assert_match(VALIDATION_PATTERN[:amount_regex], card[:available_balance])

    card[:transactions].each do |transaction|
      assert(transaction[:date].is_a? Date)
      assert(!transaction[:description].empty?)
      assert_match(VALIDATION_PATTERN[:amount_regex], transaction[:amount])
    end
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
    card = @fetcher.fetch_card(Enum::CardNumber::VISA_VALE_VALID_NUMBER)
    assert_card(card)
  end

  test "fetch card transactions since date" do
    since = Date.parse('01-03-2013')
    card = @fetcher.fetch_card(Enum::CardNumber::VISA_VALE_VALID_NUMBER, { since: since } )

    card[:transactions].each do |transaction|
      assert(transaction[:date] >= since, "#{transaction[:date]} is not in a valid period.")
    end
  end

  test "no information is fetched when transactions hash has not changed" do
    card = @fetcher.fetch_card(Enum::CardNumber::VISA_VALE_VALID_NUMBER, { transactions_hash: "7cdcd6738dcc783504ae222894e24b0db5f4b32f" } )
    assert(card.empty?, "card should be empty")
  end

  test "check transactions are same" do
    assert(@fetcher.send(:transactions_are_same?, Enum::CardNumber::VISA_VALE_VALID_NUMBER, "7cdcd6738dcc783504ae222894e24b0db5f4b32f"), "transactions hash should be equal")
  end
end