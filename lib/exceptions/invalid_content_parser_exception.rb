module Exceptions
  class InvalidContentParserException < StandardError
      attr_reader :message
      def initialize(message = nil)
        if message.nil?
          message = "InvalidContentParserException: the content provided to prepare() method is not valid."
        end

        @message = message
      end
  end
end