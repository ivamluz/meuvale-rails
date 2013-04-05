require 'test_helper'

class VisaValeParserTest < ActiveSupport::TestCase
  VALIDATION_PATTERN = {
    :card_number_regex   => /[0-9]{16}/,
    :date_regex          => /[0-9]{1,2}\/[0-9]{1,2}/,
    :optional_date_regex => /([0-9]{1,2}\/[0-9]{1,2})?/,
  }

  def setup
    @parser = Parsers::VisaValeParser.new
    @html_helper = Helpers::Html.new
  end
 
  def teardown
    @parser = nil
    @html_helper = nil
  end

  def get_expected_valid_card
    card = {
      :type => 'visa_vale',
      :number => '4058760402961025',
      :last_charged_at => '26/01',
      :last_charge_amount => 220.00,
      :next_charge => '',
      :next_charge_amount => 0.00,
      :available_balance => 178.99,
      :transactions => [
        {
          :date => '31/01',
          :description => 'RESTAURANTE TASTY',
          :amount => 16.77,
        },
        {
          :date => '30/01',
          :description => 'GRUPO GFB',
          :amount => 11.57,
        },
        {
          :date => '06/09',
          :description => 'THIANE ADM RESTAURANTE',
          :amount => 18.20,
        },
        {
          :date => '05/09',
          :description => 'VERDE SALADAS E SUCOS',
          :amount => 10.90,
        }
      ]
    }

    card
  end

  def get_expected_available_periods
    [
      '01/2013',
      '12/2012',
      '11/2012',
      '10/2012',
    ]
  end

  test "exception is raised when parser is not prepared" do
    exception = assert_raise(Exceptions::ParserNotPreparedException) { @parser.parse() }
    assert_equal(exception.message, "ParserNotPreparedException: prepare() method should be called before calling parse().")
  end

  test "exception is raised when invalid content is prepared" do
    exception = assert_raise(Exceptions::InvalidContentParserException) do
      @parser.prepare(nil).parse
    end

    assert_equal(exception.message, "InvalidContentParserException: the content provided to prepare() method is not valid.")
  end

  test "exception is raised for invalid card number" do
    exception = assert_raise(Exceptions::InvalidCardNumberException) do
      html = Helpers::Html::get_test_html(Helpers::Html::TEST_HTML[:visa_vale_invalid_card_number])
      @parser.prepare(html).parse
    end
  end

  test "exception is raised when invalid error is returned from provider" do
    exception = assert_raise(Exceptions::InvalidResultReturnedFromProviderException) do
      html = Helpers::Html::get_test_html(Helpers::Html::TEST_HTML[:visa_vale_invalid_response])
      @parser.prepare(html).parse
    end
  end

  test "parse basic card info" do
    html = Helpers::Html::get_test_html(Helpers::Html::TEST_HTML[:visa_vale_valid_card_with_transactions])
    card = @parser.prepare(html).parse

    expected_card = self.get_expected_valid_card

    card.each do |key, value|
      if not value.kind_of?(Array)
        assert_equal(expected_card[key], value)
      end
    end
  end

  test "parse card transactions" do
    html = Helpers::Html::get_test_html(Helpers::Html::TEST_HTML[:visa_vale_valid_card_with_transactions])
    card = @parser.prepare(html).parse

    card[:transactions].each do |transaction|
      assert_match(VALIDATION_PATTERN[:date_regex], transaction[:date], "Failed asserting transaction date format.")
      assert(!transaction[:description].empty?, "Failed asserting transaction description is not empty")
      assert((transaction[:amount].is_a? Float), "Failed asserting transaction amount format.")
    end
  end

  test "parse card without transactions" do
    html = Helpers::Html::get_test_html(Helpers::Html::TEST_HTML[:visa_vale_valid_card_without_transactions])
    card = @parser.prepare(html).parse

    assert(!card[:number].empty?)
    assert(card[:transactions].kind_of?(Array))
    assert(card[:transactions].empty?)
  end

  test "parse available periods for valid card with transactions" do
    html = Helpers::Html::get_test_html(Helpers::Html::TEST_HTML[:visa_vale_valid_card_with_transactions])
    available_periods = @parser.prepare(html).parse_available_periods

    assert_equal(self.get_expected_available_periods, available_periods)
  end

  test "parse available periods for valid card without transactions" do
    html = Helpers::Html::get_test_html(Helpers::Html::TEST_HTML[:visa_vale_valid_card_without_transactions])
    available_periods = @parser.prepare(html).parse_available_periods

    assert_equal(self.get_expected_available_periods, available_periods)
  end

  test "exception is raised when parsing available periods for invalid card number" do
    exception = assert_raise(Exceptions::InvalidCardNumberException) do
      html = Helpers::Html::get_test_html(Helpers::Html::TEST_HTML[:visa_vale_invalid_card_number])
      @parser.prepare(html).parse_available_periods
    end
  end

  test "exception is raised when parsing available periods for invalid result returned from server" do
    exception = assert_raise(Exceptions::InvalidResultReturnedFromProviderException) do
      html = Helpers::Html::get_test_html(Helpers::Html::TEST_HTML[:visa_vale_invalid_response])
      @parser.prepare(html).parse_available_periods
    end
  end
end