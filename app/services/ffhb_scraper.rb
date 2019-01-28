class FfhbScraper
  FFHB_94_URL = 'http://www.ff-handball.org/competitions/championnats-departementaux/94-comite-du-val-de-marne.html'

  def scrape_results
    page = Mechanize.new.get(FFHB_94_URL)

    championnats = page.css('.chpts > li')

    championnats_seniors_martigua = championnats.select do |championnat|
      championnat.css('.div-toggler').text[/\+16 Ans.*Masculine/] &&
        championnat.css('.eq p').map(&:text).any? { |name| name[/MARTIGUA/] }
    end

    rankings = championnats_seniors_martigua.map { |championnat| championnat.css('.cls') }.flatten.compact

    raise 'Unable to scrape FFHB' if rankings.empty? # do not update on scrapping errors

    rankings.each do |ranking|
      team_name = ranking.css('.eq').find { |eq| eq.text[/MARTIGUA/] }&.text
      next unless team_name

      scrapped_ranking = ScrappedRanking.find_or_initialize_by(championship_number: team_name)
      scrapped_ranking.update! scrapped_content: ranking.to_html, updated_at: Time.current # force update
    end
  end
end
