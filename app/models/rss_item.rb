# encoding: UTF-8

class RssItem < ActiveRecord::Base
  belongs_to :rss_target do
    def only_active
      find :all, :conditions=>["active=1"]
    end
  end
  has_many :classified_paragraphs, :order => "sequence_number ASC" do
    def hasone?
      find :first
    end    
    def hasone?(quote_target_id)
      find :first, :conditions=>["quote_target_id = ?", quote_target_id]
    end    
    def for_quote_target(quote_target_id)
      find :all, :conditions=>["quote_target_id=?",quote_target_id]
    end
  end
  
  def setup(rss_item,rss_target=nil)
    self.guid = rss_item.db_guid
    self.rss_target_id = rss_target.id if rss_target
    self.title = rss_item.title.to_s
    self.link = rss_item.link.to_s
    self.pubDate = rss_item.db_pub_date.to_s
    self.description = rss_item.db_description.to_s
    self.compressed_page = Zlib::Deflate.deflate(rss_item.page, Zlib::BEST_COMPRESSION)
  end

  def page
    if self.compressed_page
      begin
        Zlib::Inflate.inflate(self.compressed_page)
      rescue
        "ZLIB ERROR"
      end
    else
      content = self.rss_target.parser.to_class.get_html_page(self.link)
      self.compressed_page = Zlib::Deflate.deflate(content, Zlib::BEST_COMPRESSION)
      save
      content
    end
  end
  
  def parse_paragraphs
    p = []
    p << self.title
    p | self.rss_target.parser.to_class.parse_paragraphs(self.page, self.link)
  end

  def get_clean_page      
    s = HTML::WhiteListSanitizer.new
    s.sanitize(ParagraphTools.pre_clean_html(self.page))
  end
  
  def paragraphs(quote_target_id)
    @quote_target=QuoteTarget.find(quote_target_id)
    create_paragraphs unless ClassifiedParagraph.find(:first, :conditions=>["rss_item_id = ? AND quote_target_id = ?", self.id, @quote_target.id])
    self.classified_paragraphs.for_quote_target(@quote_target.id)
  end
   
  def self.create_paragraphs_ext(rss_feed_item,fixed_target,save,all_targets,rss_target)
    r = RssItem.new
    r.rss_target = rss_target
    r.setup(rss_feed_item)
    r.create_paragraphs(fixed_target,save,all_targets)
  end
  
  def calais_quotes
    CalaisTools.calais_quotes(parse_paragraphs.join("\n\n"))
  end
   
  def create_paragraphs(fixed_target=nil,save=true,all_targets=false)
    if fixed_target
      target=fixed_target
    else
      target=@quote_target
    end
    QuoteTarget.find(:all).each { |t| target.search_strings+="|#{t.search_strings}" } if all_targets
    new_paragraphs = parse_paragraphs
    sequence_number = 0
    processed_paragraphs_txts = []
    new_paragraphs.each do |paragraph_text|
      processed_paragraph_text = ParagraphTools.replace_search_string(target.search_strings, paragraph_text)     
      next unless processed_paragraph_text.index(ST_RATE_TARGET_TXT)
      new_paragraph = ClassifiedParagraph.new
      processed_paragraph_text = new_paragraph.import_and_save(1, self.id, sequence_number+=1, target.id, paragraph_text, processed_paragraph_text, save)
      processed_paragraphs_txts << processed_paragraph_text
    end
    processed_paragraphs_txts
  end  
end
