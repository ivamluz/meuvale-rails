module Mock
  class Connector
    def get(url)
      html_content = ''

      if url.include? Enum::CardNumber::VISA_VALE_VALID_NUMBER
        html_content = Helpers::Html::get_test_html(Helpers::Html::TEST_HTML[:visa_vale_valid_card_with_transactions])
      elsif url.include? Enum::CardNumber::VISA_VALE_INVALID_NUMBER
        html_content = Helpers::Html::get_test_html(Helpers::Html::TEST_HTML[:visa_vale_invalid_card_number])
      end

      html_content
    end
  end
end