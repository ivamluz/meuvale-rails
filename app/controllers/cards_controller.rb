class CardsController < ActionController::Base
  def show()    
    respond_to do |format|

      format.json do
        begin
          if !Card::TYPES.has_value? params[:type]
            raise Exceptions::InvalidCardTypeException
          end

          fetcher = Fetchers::VisaValeFetcher.new(Connectors::Connector.new)
          card = fetcher.fetch_card(params[:number])
        
          render :json => card.to_json
        rescue Exceptions::InvalidCardNumberException,
               Exceptions::InvalidCardTypeException => ex
          logger.error ex

          raise ActiveRecord::RecordNotFound
        end
      end
    end
  end
end