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

    # valid limiting_options are:
    # - since: Date object from when to start fetching card transactions
    # - transactions_hash: a SHA-1 hash from the transactions HTML
    def fetch_card(card_number, limiting_options = {})
      card = {}

      if transactions_are_same? card_number, limiting_options[:transactions_hash]
        return card
      end

      periods = self.get_urls_to_fetch_by_period(card_number)
      periods.each do |period, url|        
        unless period_skippable? period: period, since: limiting_options[:since]
          response = @connector.get(url)
          partial_card = @parser.prepare(response).parse

          partial_card[:transactions].map! do |transaction|
            year = get_year_from_period(period)
            transaction[:date] = transaction[:date].concat("/#{year}").to_date

            transaction
          end        

          if card.empty?
            card = partial_card
            card[:transactions_hash] = get_transactions_hash(card_number)
          else
            card[:transactions].push(*partial_card[:transactions])
          end
        end
      end

      unless card.empty?
        [:last_charged_at, :next_charge].each do |charge_date|
          unless card[charge_date].empty?
            first_period = periods.first.first
            year = get_year_from_period(first_period)

            card[charge_date] = card[charge_date].concat("/#{year}").to_date
          end
        end
      end

      card
    end

    protected
    def get_urls_to_fetch_by_period(card_number)
      response = get_initial_content(card_number)

      urls = {}
      @parser.prepare(response).parse_available_periods.each_with_index do |period, period_id|
        urls[period] = (BASE_URL.sub '__CARD_NUMBER__', card_number) + '&periodoSelecionado=' + period_id.to_s
      end

      urls
    end

    protected
    def get_initial_content(card_number)
      initial_url = BASE_URL.sub '__CARD_NUMBER__', card_number

      @initial_content ||= @connector.get(initial_url)
    end

    protected
    def get_year_from_period(period)
      period.gsub /^([0-9]{2})\/([0-9]{4})$/, '\2'
    end

    # valid options are:
    # - period: string with format MM/YYYY
    # - since: Date object
    protected
    def period_skippable?(options)
      if options[:period].nil?
        raise ArgumentError.new(":period argument is required")
      end

      skip = false
      unless options[:period].nil? or options[:since].nil?
        month, year = options[:period].match(/([0-9]{2})\/([0-9]{4})/).captures
        period = DateTime.new(year.to_i, month.to_i, 1)

        skip = period < options[:since]
      end
    end

    protected
    def get_transactions_hash(card_number)
      @parser.prepare(get_initial_content card_number).get_transactions_hash
    end

    protected
    def transactions_are_same?(card_number, transactions_hash)
      transactions_hash == @parser.prepare(get_initial_content card_number).get_transactions_hash
    end
  end
end