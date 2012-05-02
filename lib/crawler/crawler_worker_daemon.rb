# encoding: UTF-8

$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require 'rss/1.0'
require 'rss/2.0'

require "#{File.expand_path(File.dirname(__FILE__))}/../rss_addons.rb"
require "#{File.expand_path(File.dirname(__FILE__))}/../daemon_tools/base_daemon.rb"

class CrawlerWorker < BaseDaemonWorker
  def process_rss_target
    info("process_rss_target #{@rss_target.url}")
    @rss_target.parser.to_class.feed_rss_items(@rss_target).each do |feed_rss_item|
      next if feed_rss_item.link.to_s.index("video=")
      @to_search = nil
      QuoteTarget.find(:all, :conditions => "active = 1").each do |quote_target|
        unless ProcessedRssItem.find(:first,:conditions=>["guid = ? AND quote_target_id = ?",feed_rss_item.db_guid,quote_target.id])
          old_rss_item = RssItem.find(:first, :conditions=>["title = ? AND rss_target_id = ?",feed_rss_item.title.to_s, @rss_target.id])
          info("DUP DEBUG: feed_rss_item title: #{feed_rss_item.title.to_s} link: #{feed_rss_item.link.to_s} @rss_target.id #{@rss_target.id}")
          if old_rss_item
            info("DUP DEBUG: old_rss_item title: #{old_rss_item.title}")
          else
            info("DUP DEBUG: DID NOT FIND OLD RSS ITEM")
          end
          if old_rss_item and old_rss_item.created_at > Time.now-3.days
            info("DUP DEBUG: Not processing #{old_rss_item.title} as it has a duplicate title")
          else
            info("DUB DEBUG: Processing...")
            para = RssItem.create_paragraphs_ext(feed_rss_item,quote_target,false,false,@rss_target)
            @to_search = ""
            @to_search = para.join(" ") if para.length>0
            info("Checking keywords: \"#{quote_target.search_strings.downcase}\" in #{feed_rss_item.title.downcase} from #{@rss_target.title}")
            info("To search: #{@to_search}")
            if @to_search != ""
              info("Saving: #{feed_rss_item.title} from #{@rss_target.title}")
              current_item = RssItem.find_by_guid(feed_rss_item.db_guid)
              unless current_item
                rss_item = RssItem.new
                rss_item.setup(feed_rss_item,@rss_target)
                rss_item.save
                quote_target.rss_items << rss_item
              else
                info("found rss_item in database from guid")
                unless quote_target.rss_items.include?(current_item)
                  quote_target.rss_items << current_item
                  info("linking to quote target")
                end
              end
            end
          end
          processed_rss_item = ProcessedRssItem.new
          processed_rss_item.setup(feed_rss_item.db_guid, quote_target.id)
          processed_rss_item.save
        else
          info("already processed #{feed_rss_item.title} from #{@rss_target.title}")
        end
      end
    end
  end
  
  def process_yahoo_quote_target
    url = "http://download.finance.yahoo.com/d/quotes.csv?s=#{@quote_target.symbol[0..2]}#{@quote_target.symbol[4..6]}=X&f=l1&e=.csv"
    debug(url)
    raw_quote_data = Net::HTTP.get(URI.parse(url))
    debug(raw_quote_data)
    quote_data = raw_quote_data.split(",")
    if quote_data
      quote_value = QuoteValue.new
      quote_value.quote_target_id = @quote_target.id
      quote_value.data_time = Time.now
      quote_value.import_csv_data(@logger,quote_data)
      quote_value.save
    end
  end
  
  def poll_for_rss_work
    info("poll_for_rss_work")
    @rss_target = RssTarget.find(:first, :conditions => "active = 1 AND last_processing_time < NOW() - processing_time_interval", :lock => true)
    if @rss_target
      @rss_target.last_processing_time = Time.now
      @rss_target.save
      process_rss_target
    end
  end

  def poll_for_yahoo_quote_work
    info("poll_for_quote_work")
    @quote_target = QuoteTarget.find(:first, :conditions => "active = 1 AND yahoo_quote_enabled = 1 AND last_yahoo_processing_time < NOW() - processing_time_interval", :lock => true)
    if @quote_target
      @quote_target.last_yahoo_processing_time = Time.now
      @quote_target.save
      process_yahoo_quote_target
    end
  end

  def poll_for_work
    debug("poll_for_work")
    3.times {poll_for_yahoo_quote_work}
    poll_for_rss_work
  end
end

f = File.open( File.dirname(__FILE__) + '/config/worker.yml')
worker_config = YAML.load(f)

crawler_worker = CrawlerWorker.new(worker_config, Logger.new( File.join(File.dirname(__FILE__), "crawler_worker_#{ENV['RAILS_ENV']}.log")))
crawler_worker.run
