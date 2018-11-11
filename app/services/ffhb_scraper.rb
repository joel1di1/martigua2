class FfhbScraper
  def scrape_results
    page = Mechanize.new.get('http://www.ff-handball.org/competitions/championnats-departementaux/94-comite-du-val-de-marne.html')

    championnats = page.css('.chpts > li')

    championnats_seniors = championnats.select{ |championnat| championnat.css('.div-toggler').text[/\+16.*Masculine/] }

    championnats_seniors_martigua = championnats_seniors.select do |championnat|
      championnat.css('.eq p').map(&:text).any?{ |name| name[/MARTIGUA/]}
    end

    classements = championnats_seniors_martigua.map{ |championnat| championnat.css('.cls').first&.to_html }


  end
end