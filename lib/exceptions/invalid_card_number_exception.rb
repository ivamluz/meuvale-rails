module Exceptions
  class InvalidCardNumberException < StandardError
      attr_reader :message, :number
      def initialize(number, message = nil)
        if message.nil?
          message = "InvalidCardNumberException: The provided card number is not valid: " + number.to_s()
        end

        @number = number
        @message = message
      end
  end
end