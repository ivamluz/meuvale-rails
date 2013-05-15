class CardUpdater
  def initialize(fetcher)
    @fetcher = fetcher
  end

  # Updates all cards updated before the given date.
  # Return the total number of cards updated.
  def update_all_updated_before(date)
    cards = Card.updated_before(date)

    total_updated = 0

    cards.each do |card|
      card_info = @fetcher.fetch_card card.number, since: card.updated_at.in_time_zone('Brasilia')

      if (card.updated_at < card.update_with_transactions!(card_info).updated_at)
        total_updated += 1
      end
    end

    total_updated
  end
end