# frozen_string_literal: true

class GueulesdeboisCheckJob
  include Sidekiq::Job

  sidekiq_options queue: :low

  def perform
    scraped = GueulesdeboisScraper.call
    Rails.logger.info "GueulesdeBois: #{scraped.size} événement(s) amuse-gueule trouvé(s) sur le site"

    known_urls = GueulesdeboisEvent.pluck(:event_url).to_set

    new_events = scraped.filter_map do |event|
      next if known_urls.include?(event[:event_url])

      GueulesdeboisEvent.create!(title: event[:title], event_url: event[:event_url])
    end

    if new_events.any?
      Rails.logger.info "GueulesdeBois: #{new_events.size} nouvel(aux) événement(s) détecté(s), envoi d'un email"
      GueulesdeboisMailer.notify_new_amuse_gueule(new_events).deliver_now
    else
      Rails.logger.info 'GueulesdeBois: aucun nouvel événement'
    end
  end
end
