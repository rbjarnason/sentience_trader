# encoding: UTF-8

require 'nokogiri'
require 'open-uri'
require 'zlib'
require 'digest/sha1'
require 'mechanize'

ST_RATE_TARGET_TXT = "sentience_trader_rate_target"
ST_RATE_TARGET_NUMBER = "sentience_trader_token_number"
ST_RATE_TARGET_DATE = "sentience_trader_token_date"
ST_RATE_TARGET_TIME = "sentience_trader_token_time"
ST_RATE_TARGET_CURRENCY_VALUE = "sentience_trader_token_currency_value"

class ParagraphTools
  def self.strip_numbers_and_dates(text)
    text = Iconv.iconv('UTF-8//IGNORE//TRANSLIT', 'ASCII',text)[0]
    text = text.gsub(Regexp.new('(\\d+)(\\.)(\\d+)',Regexp::IGNORECASE),"#{ST_RATE_TARGET_NUMBER}")
    text = text.gsub(Regexp.new('(c)([+-]?\\d*\\.\\d+)(?![-+0-9\\.])',Regexp::IGNORECASE),"#{ST_RATE_TARGET_NUMBER}")
    text = text.gsub(Regexp.new('(\\d+)(\\s+)(percent)',Regexp::IGNORECASE),"#{ST_RATE_TARGET_NUMBER} percent")
    text = text.gsub(Regexp.new('(\\d+)(\\s+)(billion)',Regexp::IGNORECASE),"#{ST_RATE_TARGET_NUMBER}")
    text = text.gsub(Regexp.new('(\\d+)(\\s+)(million)',Regexp::IGNORECASE),"#{ST_RATE_TARGET_NUMBER}")
    text = text.gsub("C$","")
    text = text.gsub("H$","")
    text = text.gsub("$","")
    text = text.gsub("£","")
    text = text.gsub("€","")
    text = text.gsub("\"","")
    text = text.gsub("\'","")
    text = text.gsub(Regexp.new("((?:(?:[0-1][0-9])|(?:[2][0-3])|(?:[0-9])):(?:[0-5][0-9])(?::[0-5][0-9])?(?:\\s?(?:am|AM|a.m.|A.M|pm|PM|p.m.|P.M.))?)"),"#{ST_RATE_TARGET_TIME}")
    text = text.gsub(Regexp.new('(\\d+)(:)(\\d+)(\\s+)(.)(.)',Regexp::IGNORECASE),"#{ST_RATE_TARGET_TIME}")
    re1='((?:Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sept(?:ember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?))'
    re2='(\\.)'
    re3='(\\s+)'
    re4='((?:(?:[0-2]?\\d{1})|(?:[3][0,1]{1})))(?![\\d])'
    re=(re1+re2+re3+re4)
    text = text.gsub(Regexp.new(re,Regexp::IGNORECASE),"#{ST_RATE_TARGET_DATE}")
    re=(re1+re3+re4)
    text = text.gsub(Regexp.new(re,Regexp::IGNORECASE),"#{ST_RATE_TARGET_DATE}")
    text = text.gsub(Regexp.new('((?:Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sept(?:ember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?))(\\s+)((?:(?:[1]{1}\\d{1}\\d{1}\\d{1})|(?:[2]{1}\\d{3})))(?![\\d])',Regexp::IGNORECASE),"#{ST_RATE_TARGET_TIME}")    
  end
  
  def self.strip_various(text)
    text.gsub("(bloomberg) -- "," ")
  end
  
  def self.replace_search_string(search_strings, text)
    text = " #{text.downcase.gsub("\n\r"," ").gsub("\n"," ").gsub("\r"," ")}"
    text = Iconv.iconv('UTF-8//IGNORE//TRANSLIT', 'ASCII',text)[0]
    search_strings.downcase.split("|").sort {|x,y| y.length <=> x.length }.each do |replacement|
      replacement = Iconv.iconv('UTF-8//IGNORE//TRANSLIT', 'ASCII',replacement)[0]
      if replacement=="dollar"
        dollar_ignore = ["caribbean","australian","aussie","bahamian","barbadian","belize","bermudian","brunei",
        "canadian", "islands","fijian","guyanese","kong","jamaican","liberian","namibian","zealand","kiwi",
        "singapore","surinamese","taiwan","tobago","zimbabwean"]
        new_text_a = []
        text_a = text.split
        text_a.each_with_index do |word,index|
          word = word.gsub("dollar","x0llx3") if word.index("dollar") and index>0 and dollar_ignore.include?(text_a[index-1])
          new_text_a << word
        end
        text = new_text_a.join(" ")
      end
      text = text.gsub(" #{replacement} "," #{ST_RATE_TARGET_TXT} ").
                  gsub(" #{replacement}."," #{ST_RATE_TARGET_TXT}.").
                  gsub(" #{replacement},"," #{ST_RATE_TARGET_TXT},").
                  gsub(" #{replacement};"," #{ST_RATE_TARGET_TXT};").
                  gsub(" #{replacement}s "," #{ST_RATE_TARGET_TXT}s ").
                  gsub(" #{replacement}'s "," #{ST_RATE_TARGET_TXT}'s ").
                  gsub(" #{replacement}`s "," #{ST_RATE_TARGET_TXT}`s ").
                  gsub(" #{replacement}s."," #{ST_RATE_TARGET_TXT}s. ").
                  gsub(" #{replacement}'s,"," #{ST_RATE_TARGET_TXT}'s, ").
                  gsub(" #{replacement}`s;"," #{ST_RATE_TARGET_TXT}`s; ")
      text = text.gsub("x0llx3","dollar") if replacement=="dollar"
    end
    text
  end

  def self.pre_clean_html(html)
    html.downcase.gsub(/(\r\n|\n\r|\n|\r)/,'[[[NEWLINE]]]').
                  gsub("((<!-- )((?!<!-- ).)*( -->))","").
                  gsub("((<!(.*?)(--.*?--\s*)+(.*?)>))","").
                  gsub(/<script([^>]+)>.*?<\/script>/,'').
                  gsub(/<style([^>]+)>.*?<\/style>/,'').
                  gsub(/<!--(.*?)-->[\n]?/m,"").
                  gsub(/<!doctype(.*?)>[\n]?/m,"").
                  gsub(/<!(.*?)>[\n]?/m,"").
                  gsub('[[[NEWLINE]]]',"\n")
  end

  def self.get_via_lynx(url)
    filename="#{RAILS_ROOT}/tmp/getlynx#{rand(4343433232)}.html"
    system("lynx -accept_all_cookies -source \"#{url}\" > #{filename}")
    data = File.open(filename).read
    File.delete(filename)
    data
  end
end
