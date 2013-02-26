module Exceptions
  class ParserNotPreparedException < StandardError
      attr_reader :message
      def initialize(message = nil)
        if message.nil?
          message = "ParserNotPreparedException: prepare() method should be called before calling parse()."
        end

        @message = message
      end
  end
end