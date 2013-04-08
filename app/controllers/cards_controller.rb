class CardsController < ActionController::Base
  def show()    
    respond_to do |format|

      format.json do
        begin
          fetcher = Fetchers::FetcherFactory.createByType(params[:type])
          card = fetcher.fetch_card(params[:number])

          render :json => card.to_json
        rescue Exceptions::InvalidCardNumberException,
               Exceptions::InvalidCardTypeException => ex
          logger.error ex

          # render :file => "#{Rails.root.to_s}/public/404", 
          #        :formats => [:html], :layout => false, :status => 404
          render :text => "404 Not found", :status => 404
        end
      end
    end
  end
end