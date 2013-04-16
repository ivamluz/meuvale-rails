module Helpers
  class Html
    TEST_HTML = {
      :visa_vale_invalid_card_number => 'visa_vale_invalid_card.html',
      :visa_vale_invalid_response => 'visa_vale_invalid_result.html',
      :visa_vale_valid_card_with_transactions => 'visa_vale_90_days_card_extract.html',
      :visa_vale_valid_card_without_transactions => 'visa_vale_card_without_transactions.html',      
    }
    TEST_HTML[:visa_vale_by_period] = []
    4.times do |i|
      TEST_HTML[:visa_vale_by_period][i] = "visa_vale_period_#{i}.html"
    end

    def self.get_test_html(filename)
      unless (TEST_HTML.has_value? filename) or (TEST_HTML[:visa_vale_by_period].include? filename)
        raise ArgumentError
      end

      file_path = Rails.root.join('test', 'data', filename).to_s()

      File.read(file_path)
    end
  end
end