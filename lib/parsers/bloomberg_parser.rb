class BloombergParser < BaseParser
  def self.feed_rss_items(rss_target)
    items = []
    doc = Nokogiri::HTML(ParagraphTools.get_via_lynx(rss_target.url))
    doc.xpath('//a[@class="summheadline"]').each do |e|
      puts e.text
      puts e.attributes["href"]
      item = RSS::RDF::Item.new
      item.title = e.text
      item.link = "http://www.bloomberg.com"+e.attributes["href"]
      puts item
      items << item
    end
    items    
  end
  
  def self.parse_paragraphs(page, link)
    parsed_paragraphs = []
    doc = Nokogiri::HTML(page)
    doc.xpath('//p').each do |e|
      sanitized = sanitize_base(e.text)
      parsed_paragraphs << sanitized unless sanitized.length<40
    end
    parsed_paragraphs
  end
end