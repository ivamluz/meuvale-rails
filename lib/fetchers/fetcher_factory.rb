module Fetchers
  class FetcherFactory
    def self.createByType(type)
      case type
      when Card::TYPES[:visa_vale]
        Fetchers::VisaValeFetcher.new(Connectors::Connector.new)
      else
        raise(Exceptions::InvalidCardTypeException, "type argument must be one of Card::TYPES values")
      end
    end
  end
end