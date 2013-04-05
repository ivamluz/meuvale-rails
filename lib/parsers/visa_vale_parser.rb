# encoding: utf-8

module Parsers
  class VisaValeParser 
    @document = nil

    def prepare(html)
      if html.nil? or html.empty?
        raise Exceptions::InvalidContentParserException
      end

      @document = Nokogiri::HTML(html, nil, 'ISO-8859-1')

      self
    end

    def parse
      self.check_for_exceptions

      card = self.parse_basic_card_info
      unless card.empty?
        card[:type] = 'visa_vale'
        card[:transactions] = self.parse_transactions
      end

      card
    end

    def parse_available_periods
      self.check_for_exceptions

      month_regex = /(janeiro|'fevereiro|março|abril|maio|junho|julho|agosto|setembro|outubro|novembro|dezembro)/
      month_mapping = {
        'janeiro'   => '01',
        'fevereiro' => '02',
        'março'     => '03',
        'abril'     => '04',
        'maio'      => '05',
        'junho'     => '06',
        'julho'     => '07',
        'agosto'    => '08',
        'setembro'  => '09',
        'outubro'   => '10',
        'novembro'  => '11',
        'dezembro'  => '12',
      }

      available_periods = []
      @document.xpath(".//*[@id='comboPeriodo']/option[contains(.,'/')]").each do |node|
        available_periods[node.attribute('value').content.to_i] = node.content.sub(month_regex, month_mapping)
      end

      available_periods
    end

    protected
    def check_for_exceptions
      if @document.blank?
        raise Exceptions::ParserNotPreparedException
      end

      unless self.valid_result?
        raise Exceptions::InvalidResultReturnedFromProviderException
      end

      unless self.card_exists?
        raise Exceptions::InvalidCardNumberException
      end
    end

    protected
    def valid_result?
      node = @document.at_xpath(".//*[@id='frmSaldoExtratoPFS']/table/tr/td/text()")

      valid = true
      unless node.nil?
        valid = not(node.content.include? "para consulta de saldo e extrato Visa Vale")
      end
    end

    protected
    def card_exists?
      node = @document.at_xpath(".//*[@id='frmSaldoExtratoPFS']/table[2]/tr/td")

      valid = true
      unless node.nil?
        valid = not(node.content == "Cartão inválido.")
      end
    end

    protected
    def parse_basic_card_info
      selectors = self.get_basic_card_info_xpath_selectors_per_field

      amount_fields = [:last_charge_amount, :next_charge_amount, :available_balance]

      card = {}
      selectors.each do |field_symbol, selector|
        node = @document.at_xpath(selector)
        unless node.nil?
          card[field_symbol] = node.content
          if amount_fields.include? field_symbol
            card[field_symbol] = self.to_float(node.content)
          end
        end
      end

      card
    end

    protected
    def get_basic_card_info_xpath_selectors_per_field
      {
        :number             => ".//*[@id='frmSaldoExtratoPFS']/table[1]/tr[2]/td[2]",
        :last_charged_at    => ".//*[@id='frmSaldoExtratoPFS']/table[1]/tr[3]/td[2]",
        :last_charge_amount => ".//*[@id='frmSaldoExtratoPFS']/table[1]/tr[3]/td[3]",
        :next_charge        => ".//*[@id='frmSaldoExtratoPFS']/table[1]/tr[4]/td[2]",
        :next_charge_amount => ".//*[@id='frmSaldoExtratoPFS']/table[1]/tr[4]/td[3]",
        :available_balance  => ".//*[@id='frmSaldoExtratoPFS']/table[4]/tr/td[2]",
      }
    end

    protected
    def to_float(value)
      (value.gsub /.*?([0-9]+),([0-9]+)$/, '\1.\2').to_f
    end

    protected
    def parse_transactions
      transactions = []

      if self.card_has_transactions?
        entries = @document.xpath(".//*[@id='frmSaldoExtratoPFS']/table[3]/tr")
        entries.each do |entry|
          transactions.push({
            :date        => entry.at_xpath("td[1]").content,
            :description => entry.at_xpath("td[2]").content,
            :amount      => self.to_float(entry.at_xpath("td[3]").content),
          })
        end
      end

      transactions
    end

    protected
    def card_has_transactions?
      node = @document.at_xpath(".//*[@id='frmSaldoExtratoPFS']/table[3]/tr/td")

      valid = true
      unless node.nil?
        valid = not(node.content == "Não há movimentações para o período selecionado.")
      end
    end
  end
end