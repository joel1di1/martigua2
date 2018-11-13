class FfhbScraper
  def scrape_results
    page = Mechanize.new.get('http://www.ff-handball.org/competitions/championnats-departementaux/94-comite-du-val-de-marne.html')

    championnats = page.css('.phase_list > ul > li')

    championnats_seniors_martigua = championnats.select do |championnat|
      championnat.css('.div-toggler').text[/Plus 16 Ans.*Masculine/] &&
        championnat.css('.eq p').map(&:text).any?{ |name| name[/MARTIGUA/]}
    end

    rankings = championnats_seniors_martigua.map{ |championnat| championnat.css('.cls').first&.to_html }.compact

    raise 'Unable to scrape FFHB' if rankings.empty? # do not update on scrapping errors

    if (rankings - ScrappedRanking.all.pluck(:scrapped_content)).empty?
      ScrappedRanking.all.update_all updated_at: Time.current
    else
      ScrappedRanking.transaction do
        ScrappedRanking.all.update_all deleted_at: Time.current
        rankings.each do |ranking|
          ScrappedRanking.create! scrapped_content: ranking
        end
      end
    end
  end
end
