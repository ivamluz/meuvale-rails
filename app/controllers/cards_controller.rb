class CardsController < ApplicationController
  def show()    
    respond_to do |format|
      format.json do
        begin
          Card::validate_number_format_by_type(params[:number], params[:type])

          card = Card.find(:first, :conditions => { number: params[:number], card_type: params[:type] }) || not_found

          render :json => card.to_json(
                :include => { :transactions => { :except => [:id, :card_id, :created_at, :updated_at] } },
                :except => [ :id ]
              )
        rescue ActionController::RoutingError,
               Exceptions::InvalidCardNumberException,
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

      status = :ok

      card = Card.find(:first, :conditions => { number: params[:number], card_type: params[:type] })
      if not card
        fetcher = Fetchers::FetcherFactory.createByType(params[:type])
        card = fetcher.fetch_card(params[:number])
        card = Card.create_with_transactions(card)

        status = :created
      end
      
      render :json => card.to_json(
                :include => { :transactions => { :except => [:card_id, :created_at, :updated_at] } }
              ),
             :status => status
    rescue Exceptions::InvalidCardTypeException => ex
      logger.error ex

      render :status => :bad_request, :text => "Invalid card type: #{params[:type]}"
    rescue Exceptions::InvalidCardNumberException => ex
      logger.error ex

      render :status => :bad_request, :text => "Invalid card number: #{params[:number]}"
    end
  end
end