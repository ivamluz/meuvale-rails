module Fetchers
  class VisaValeFetcher
    BASE_URL = 'http://www.cartoesbeneficio.com.br/inst/convivencia/SaldoExtrato.jsp?numeroCartao=__CARD_NUMBER__'

    def initialize(connector)
      unless connector.respond_to? :get
        raise NoMethodError.new("The given connector object doesn't respond to get() method.")
      end

      @connector = connector
      @parser = Parsers::VisaValeParser.new
    end

    def fetch_card(card_number)
      card = {};

      periods = self.get_urls_to_fetch_by_period(card_number)
      periods.each do |period, url|
        response = @connector.get(url)
        partial_card = @parser.prepare(response).parse

        partial_card[:transactions].map! do |transaction|
          year = get_year_from_period(period)
          transaction[:date] = transaction[:date].concat("/#{year}").to_date

          transaction
        end        

        if card.empty?
          card = partial_card
        else
          card[:transactions].push(*partial_card[:transactions])
        end
      end

      [:last_charged_at, :next_charge].each do |charge_date|
        unless card[charge_date].empty?
          first_period = periods.first.first
          year = get_year_from_period(first_period)

          card[charge_date] = card[charge_date].concat("/#{year}").to_date
        end
      end

      card
    end

    protected
    def get_urls_to_fetch_by_period(card_number)
      initial_url = BASE_URL.sub '__CARD_NUMBER__', card_number
      response = @connector.get(initial_url);

      urls = {}
      @parser.prepare(response).parse_available_periods.each_with_index do |period, period_id|
        urls[period] = (BASE_URL.sub '__CARD_NUMBER__', card_number) + '&periodoSelecionado=' + period_id.to_s
      end

      urls
    end

    protected
    def get_year_from_period(period)
      period.gsub /^([0-9]{2})\/([0-9]{4})$/, '\2'
    end
  end
end