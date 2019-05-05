class FfhbScraper
  FFHB_94_URL = 'http://www.ff-handball.org/'

  def scrape_results
    # page = Mechanize.new.get("#{FFHB_94_URL}competitions/championnats-departementaux/94-comite-du-val-de-marne.html")

    # championnats = page.css('.chpts > li')

    # championnats_seniors_martigua = championnats.select do |championnat|
    #   championnat.css('.div-toggler').text[/\+16 Ans.*Masculine/] &&
    #     championnat.css('.eq p').map(&:text).any? { |name| name[/MARTIGUA/] }
    # end

    # links = championnats_seniors_martigua.map { |championnat| championnat.css('.plus a') }.flatten

    # raise 'Unable to scrape FFHB' if links.empty? # do not update on scrapping errors

    links =
      [
        'http://www.ff-handball.org/competitions/championnats-departementaux/94-comite-du-val-de-marne.html?tx_obladygesthand_pi1%5Bsaison_id%5D=14&tx_obladygesthand_pi1%5Bcompetition_id%5D=11147&tx_obladygesthand_pi1%5Bphase_id%5D=35209&tx_obladygesthand_pi1%5Bgroupe_id%5D=60469&tx_obladygesthand_pi1%5Bmode%5D=single_phase&cHash=76400d94b9b7a095cc991ce01fe8f8dd',
        'http://www.ff-handball.org/competitions/championnats-departementaux/94-comite-du-val-de-marne.html?tx_obladygesthand_pi1%5Bsaison_id%5D=14&tx_obladygesthand_pi1%5Bcompetition_id%5D=11146&tx_obladygesthand_pi1%5Bphase_id%5D=36138&tx_obladygesthand_pi1%5Bgroupe_id%5D=61857&tx_obladygesthand_pi1%5Bmode%5D=single_phase&cHash=02e02774cd4ff79789f91596fd8dc1b2',
        'http://www.ff-handball.org/competitions/championnats-departementaux/94-comite-du-val-de-marne.html?tx_obladygesthand_pi1%5Bcompetition_id%5D=11148&cHash=ddd5315558bfcf118560bdb7b9486b0f',
      ]

    links.each do |link|
      all_matches_page = Mechanize.new.get(link)
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
