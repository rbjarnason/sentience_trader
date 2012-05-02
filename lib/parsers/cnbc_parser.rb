class CNBCParser < BaseParser
  def self.parse_paragraphs(page, link)
    parsed_paragraphs = []
    doc = Nokogiri::HTML(page)
    doc.xpath('//p[@class="textBodyBlack"]').each do |e|
      sanitized = sanitize_base(e.text)
      next if sanitized.index("cnbc_WSODChartLoad") or sanitized.index("document.write")
      parsed_paragraphs << sanitized unless sanitized.length<40
    end
    parsed_paragraphs
  end
end