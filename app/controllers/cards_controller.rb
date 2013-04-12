class CardsController < ActionController::Base
  def show()    
    respond_to do |format|
      format.json do
        begin
          fetcher = Fetchers::FetcherFactory.createByType(params[:type])
          card = fetcher.fetch_card(params[:number])

          render :json => card
        rescue Exceptions::InvalidCardNumberException,
               Exceptions::InvalidCardTypeException => ex
          logger.error ex

          render :text => "404 Not found", :status => 404
        end
      end
    end
  end

  def create()
    begin
      Card::validate_number_format_by_type(params[:number], params[:type])

      fetcher = Fetchers::FetcherFactory.createByType(params[:type])
      card = fetcher.fetch_card(params[:number])

      if not Card.find_by_number(params[:number])
        Card.create_with_transactions(card)
      end

      render :json => card, :status => :created
    rescue Exceptions::InvalidCardTypeException => ex
      logger.error ex

      render :status => :bad_request, :text => "Invalid card type: #{params[:type]}"
    rescue Exceptions::InvalidCardNumberException => ex
      logger.error ex

      render :status => :bad_request, :text => "Invalid card number: #{params[:number]}"
    end
  end
end