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

          # render :json => {
          #   error: 404,
          #   message: 'Not found'
          # }, :status => '404'
        rescue => ex
          logger.error ex

          render :json => {
            error: 500,
            message: 'Internal server error'
          }, :status => '500'
        end
      end
    end
  end
end