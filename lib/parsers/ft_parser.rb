require 'mechanize'

class FTParser < BaseParser
  @@agent = nil
  
  def self.feed_rss_items(rss_target)
    items = []        
    @@agent = nil
    if FTParser.confirm_login
      currency_page = @@agent.get('http://www.ft.com/markets/currencies')
      articles = ""
      currency_page.search(".//div[@class='primary article']").each do |a|
        articles+=a.to_s
      end
      currency_page.search(".//div[@class='lesser article']").each do |a|
        articles+=a.to_s
      end
      
      doc = Nokogiri::HTML(articles)
      doc.xpath('//a').each do |e|
        puts e.text
        puts e.attributes["href"]
        item = RSS::RDF::Item.new
        item.title = e.text
        if e.attributes["href"].to_s[0..3]=="http"
          item.link = e.attributes["href"]
        else
          item.link = "http://www.ft.com"+e.attributes["href"]
        end
        puts item
        items << item
      end
    end
    items
  end
    
  def self.get_html_page(link)
    ft_page_txt = ""
    if FTParser.confirm_login
      ft_page=@@agent.get(link)
      ft_page_txt = ft_page.search(".//body").to_s
    end
    ft_page_txt
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

private

  def self.confirm_login
    unless @@agent
      @@agent = WWW::Mechanize.new
      @@agent.user_agent_alias = "Linux Mozilla"
    end
    page = @@agent.get('http://www.ft.com/home/uk')
    login_confirmation = page.search(".//div[@class='ftLogin-loggedIn']")
    if login_confirmation==""
      page = @@agent.get('http://www.ft.com/home/uk')
      login_form = nil
      page.forms.each do |f|
        if f.fields and f.fields.length>0 and f.fields[0].name=="username"
          login_form = f
          break
        end
      end      
      if login_form
        login_form.username = "dave@decyphermedia.com"
        login_form.password = "detroit"
        @@agent.submit(login_form)
        sleep 2
      end
      page = @@agent.get('http://www.ft.com/home/uk')
      login_confirmation = page.search(".//div[@class='ftLogin-loggedIn']")
      if login_confirmation
        return true
      else
        return false
      end
    else
      return true
    end    
  end
end