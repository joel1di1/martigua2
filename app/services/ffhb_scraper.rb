class FfhbScraper
  FFHB_94_URL = 'http://www.ff-handball.org/competitions/championnats-departementaux/94-comite-du-val-de-marne.html'

  def scrape_results
    page = Mechanize.new.get(FFHB_94_URL)

    championnats = page.css('.chpts > li')

    championnats_seniors_martigua = championnats.select do |championnat|
      championnat.css('.div-toggler').text[/\+16 Ans.*Masculine/] &&
        championnat.css('.eq p').map(&:text).any? { |name| name[/MARTIGUA/] }
    end

    links = championnats_seniors_martigua.map { |championnat| championnat.css('.plus a') }.flatten

    raise 'Unable to scrape FFHB' if links.empty? # do not update on scrapping errors

    links.each do |link|
      all_matches_page = Mechanize.new.get("#{FFHB_ROOT}#{link.attribute('href').value}")
      inner = all_matches_page.css('.inner')
      team_name = inner.css('.eq').find { |eq| eq.text[/MARTIGUA/] }&.text
      next unless team_name

      scrapped_ranking = ScrappedRanking.find_or_initialize_by(championship_number: team_name)

      content = "<div class=\"bloc contenu\">#{inner.css('.cls').to_html}#{inner.css('#journeeCarousel').to_html}</div>"
      scrapped_ranking.update! scrapped_content: content, updated_at: Time.current # force update
    end
    'ok'
  end
end
