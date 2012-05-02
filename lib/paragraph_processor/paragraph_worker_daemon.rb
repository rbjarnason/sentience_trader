# encoding: UTF-8

$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require "#{File.expand_path(File.dirname(__FILE__))}/../daemon_tools/base_daemon.rb" 

class ParagraphWorker < BaseDaemonWorker

  def poll_for_calais_processing
    rss_item = RssItem.find(:first, :conditions=>"has_processed_calais = 0", :lock=>true)
    sequence_number = 0
    quote = nil
    if rss_item
      rss_item.calais_quotes.each do |quote|
        info("Processing quote: #{quote.inspect}")
        QuoteTarget.find(:all).each do |quote_target|
          processed_paragraph_text = ParagraphTools.replace_search_string(quote_target.search_strings, quote[:quote])     
          next unless processed_paragraph_text.index(ST_RATE_TARGET_TXT)
          new_paragraph = ClassifiedParagraph.new
          new_paragraph.import_and_save(3, rss_item.id, sequence_number+=1, quote_target.id, quote[:quote], processed_paragraph_text, true)
          person = ClassifiedPerson.import_if_unique(quote)
          new_paragraph.classified_people << person if person
        end
      end
      rss_item.has_processed_calais = true
      rss_item.save
    end
  end

  def poll_for_work
    debug("poll_for_work")
    poll_for_calais_processing
  end
end

f = File.open( File.dirname(__FILE__) + '/config/worker.yml')
worker_config = YAML.load(f)
paragraph_worker = ParagraphWorker.new(worker_config, Logger.new( File.join(File.dirname(__FILE__), "paragraph_worker_#{ENV['RAILS_ENV']}.log")))
paragraph_worker.run
