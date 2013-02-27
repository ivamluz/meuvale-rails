module Exceptions
  class InvalidCardNumberException < StandardError
      attr_reader :message
      def initialize(message = nil)
        if message.nil?
          message = "InvalidCardNumberException: The provided card number is not valid"
        end

        @message = message
      end
  end
end