namespace :meuvale do
  desc "Update out-of-date cards"
  task :update_cards => :environment do
    updater_service = CardUpdater.new(Fetchers::VisaValeFetcher.new(Connectors::Connector.new))

    since = 5.minutes.ago
    total_updated = updater_service.update_all_updated_before(since)

    puts "#{total_updated} card(s) updated before #{since} were updated."
  end
end
