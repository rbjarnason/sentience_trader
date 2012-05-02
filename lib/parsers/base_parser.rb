require 'nokogiri'

include ActionView::Helpers::SanitizeHelper

class FormattingSanitizer < HTML::Sanitizer
  cattr_accessor :included_tags, :instance_writer => false
  self.included_tags = Set.new(%w(b))

  def sanitizeable?(text)
    !(text.nil? || text.empty?)
  end

protected
  def process_node(node, result, options)
    result << node.to_s unless node.is_a?(HTML::Tag) && included_tags.include?(node.name) 
  end
end

class BaseParser
   def self.feed_rss_items(rss_target)
    content = ""
    open(rss_target.url) do |s| content = s.read end
    RSS::Parser.parse(content, false).items
  end
  
  def self.get_html_page(link)
    ParagraphTools.get_via_lynx(link)
  end
  
  def self.sanitize_base(text)
    formatting_sanitizer = FormattingSanitizer.new
    sanitizer = HTML::WhiteListSanitizer.new
    no_links = formatting_sanitizer.sanitize(text)
    sanitized = sanitizer.sanitize(no_links)
    sanitized = sanitized.gsub("\n"," ").gsub("\r"," ")
  end
end