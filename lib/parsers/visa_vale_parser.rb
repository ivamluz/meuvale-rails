module Parsers
  class VisaValeParser 
    @html = nil   
    def prepare(html)
      if html.nil? or html.empty?
        raise Exceptions::InvalidContentParserException
      end

      @html = html
    end

    def parse
      self.check_for_exceptions()
    end

    def check_for_exceptions
      if @html.nil?
        raise Exceptions::ParserNotPreparedException
      end

      raise Exceptions::InvalidCardNumberException.new(1234)
    end
  end
end