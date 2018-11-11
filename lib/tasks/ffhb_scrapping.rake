namespace :ffhb_scrapping do
  task :scrape_rankings => :environment do
    FfhbScraper.new.scrape_results
  end
end
