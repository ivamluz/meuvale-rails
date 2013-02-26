require 'test_helper'

class VisaValeParserTest < ActiveSupport::TestCase
  def setup
    @parser = Parsers::VisaValeParser.new
  end
 
  # called after every single test
  def teardown
    @parser = nil
  end

  def get_invalid_card_html
    file_path = Rails.root.join('test', 'data', 'visa_vale_invalid_card.html').to_s()

    File.read(file_path)
  end

  test "exception is raised when parser is not prepared" do
    exception = assert_raise(Exceptions::ParserNotPreparedException) { @parser.parse() }
    assert_equal(exception.message, "ParserNotPreparedException: prepare() method should be called before calling parse().")
  end

  test "exception is raised when invalid content is prepared" do
    exception = assert_raise(Exceptions::InvalidContentParserException) do
      @parser.prepare(nil)
      @parser.parse()
    end

    assert_equal(exception.message, "InvalidContentParserException: the content provided to prepare() method is not valid.")
  end

  test "exception is raised for invalid card number" do
    exception = assert_raise(Exceptions::InvalidCardNumberException) do
      @parser.prepare(self.get_invalid_card_html())
      @parser.parse()
    end
  end
end