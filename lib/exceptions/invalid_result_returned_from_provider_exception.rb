module Exceptions
  class InvalidResultReturnedFromProviderException < StandardError
      attr_reader :message
      def initialize(message = nil)
        if message.nil?
          message = "InvalidResultsReturnedFromProvider: Visa Vale website is out of service or the provided card number isn't properly formatted."
        end

        @message = message
      end
  end
end