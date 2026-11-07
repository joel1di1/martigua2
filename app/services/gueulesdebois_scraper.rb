# frozen_string_literal: true

require 'net/http'
require 'nokogiri'

class GueulesdeboisScraper
  EVENTS_URL = 'https://www.gueulesdebois.fr/events'

  def self.call
    new.call
  end

  def call
    html = fetch_page
    parse_amuse_gueule_events(html)
  end

  private

  def fetch_page
    uri = URI(EVENTS_URL)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPRedirection)
      uri = URI(response['location'])
      response = Net::HTTP.get_response(uri)
    end

    raise "Erreur HTTP #{response.code} lors du scraping de #{EVENTS_URL}" unless response.is_a?(Net::HTTPSuccess)

    response.body
  end

  def parse_amuse_gueule_events(html)
    doc = Nokogiri::HTML(html)

    doc.css('a[href*="/event/"]').filter_map do |link|
      title = link.at_css('h5')&.text&.strip
      next if title.blank?
      next unless title.downcase.include?('amuse')

      event_url = link['href']
      { title:, event_url: }
    end
  end
end
