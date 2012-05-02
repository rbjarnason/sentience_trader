require 'rubygems'
require 'open-uri'
#require 'hpricot'

namespace :utils do
  desc "Backup"
  task(:backup => :environment) do
      filename = "SentienceTrader_development_#{Time.new.strftime("%d%m%y_%H%M%S")}.sql"
      system("mysqldump -u s_trader_user --force --password=t3gv8gh42a SentienceTrader_development > /media/data1/backups/#{filename}")
      system("gzip /media/data1/backups/#{filename}")
  end
end

namespace :utils do
  desc "Scrape Technorati"
  task(:tscrape => :environment) do
    puts "GO"
    content = Net::HTTP.get(URI.parse("http://www.technorati.com/blogs/directory/business/investing?page=1"))
    doc = Hpricot(content)
    (doc/"/html/body/div[3]/div[4]/div/div[2]/ol/li").each do |e|
      puts "HOHOHO"
      puts e
      e.each do |e2|
        puts "KOKOKO"
        puts e2.inner_html
      end
    end
  end
end



