# encoding: utf-8

module Parsers
  class VisaValeParser 
    @document = nil

    def prepare(html)
      if html.nil? or html.empty?
        raise Exceptions::InvalidContentParserException
      end

      @document = Nokogiri::HTML(html, nil, 'ISO-8859-1')
    end

    def parse
      self.check_for_exceptions()
    end

    def check_for_exceptions
      if @document.blank?
        raise Exceptions::ParserNotPreparedException
      end

      if not self.valid_result?
        raise Exceptions::InvalidResultReturnedFromProviderException
      end

      if not self.card_exists?
        raise Exceptions::InvalidCardNumberException
      end
    end

    def valid_result?
      node = @document.at_xpath(".//*[@id='frmSaldoExtratoPFS']/table/tr/td/text()")

      valid = true
      if not node.nil?
        valid = not(node.content.include? "para consulta de saldo e extrato Visa Vale")
      end
    end

    def card_exists?
      node = @document.at_xpath(".//*[@id='frmSaldoExtratoPFS']/table[2]/tr/td")

      valid = true
      if not node.nil?
        valid = not(node.content == "Cartão inválido.")
      end
    end
  end
end