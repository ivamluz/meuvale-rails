module Helpers
  class Html
    TEST_HTML = {
      :visa_vale_invalid_card_number => 'visa_vale_invalid_card.html',
      :visa_vale_invalid_response => 'visa_vale_invalid_result.html',
      :visa_vale_valid_card_with_transactions => 'visa_vale_90_days_card_extract.html',
      :visa_vale_valid_card_without_transactions => 'visa_vale_card_without_transactions.html',
    }

    def self.get_test_html(filename)
      unless TEST_HTML.has_value? filename
        raise ArgumentError
      end

      file_path = Rails.root.join('test', 'data', filename).to_s()

      File.read(file_path)
    end
  end
end