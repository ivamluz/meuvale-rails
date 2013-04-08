require 'test_helper'

# TODO: Implement logic to test charge dates (when next charge is on next year)

class VisaValeFetcherTest < ActiveSupport::TestCase
  test "visa vale fetcher creation" do
    fetcher = Fetchers::FetcherFactory.createByType(Card::TYPES[:visa_vale])
    assert((fetcher.is_a? Fetchers::VisaValeFetcher), "Failed to create VisaValeFetcher instance using FetcherFactory.")
  end

  test "invalid card fetcher creation" do
    assert_raise(Exceptions::InvalidCardTypeException) { Fetchers::FetcherFactory.createByType("foo") }
  end
end