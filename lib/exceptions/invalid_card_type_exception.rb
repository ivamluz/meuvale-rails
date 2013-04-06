module Exceptions
  class InvalidCardTypeException < StandardError
      attr_reader :message
      def initialize(message = nil)
        if message.nil?
          message = "InvalidCardTypeException: The provided card type is not valid"
        end

        @message = message
      end
  end
end