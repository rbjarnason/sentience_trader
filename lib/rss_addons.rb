module RssAddons
  def db_guid
    if self.respond_to?("guid") and self.guid
      self.guid.to_s
    else
      self.link.to_s
    end
  end

  def db_pub_date
    if self.respond_to?("pubDate") and self.pubDate
      self.pubDate.to_s
    else
      Time.now.to_s
    end
  end
  
  def db_description
    if self.description
      description.to_s
    else
      ""
    end
  end

  def page
    unless @page
      @page = ParagraphTools.get_via_lynx(self.link)
      RAILS_DEFAULT_LOGGER.info("Loading from network")
    else
      RAILS_DEFAULT_LOGGER.info("Loading from cache")
    end
    @page
  end

  def parse_paragraphs
    RssItem.parse_paragraphs(self.page, self.link)
  end
end

class RSS::RDF::Item
  include RssAddons
end

class RSS::Rss::Channel::Item
  include RssAddons
end
