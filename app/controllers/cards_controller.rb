class CardsController < ActionController::Base
  def show()    
    respond_to do |format|

      format.json do
        card_number = params[:number]

        fetcher = Fetchers::VisaValeFetcher.new(Connectors::Connector.new)

        begin
          card = fetcher.fetch_card(card_number)
        
          render :json => card.to_json
        rescue Exceptions::InvalidCardNumberException => ex
          logger.error ex

          render :json => {
            error: 404,
            message: 'Not found'
          }, :status => '404'
        # rescue => ex
        #   logger.error ex

        #   render :json => {
        #     error: 500,
        #     message: 'Internal server error'
        #   }, :status => '500'
        end
      end
    end
  end
end