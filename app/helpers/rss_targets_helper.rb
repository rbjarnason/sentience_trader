# encoding: UTF-8

module RssTargetsHelper
  def color_st_targets(text)
    text.gsub("sentience_trader_rate_target","<span style=\"color: red\">token_currency</span>").
         gsub("sentience_trader_token_number","<span style=\"color: #555\">token_number</span>").
         gsub("sentience_trader_token_date","<span style=\"color: #555\">token_date</span>").
         gsub("sentience_trader_token_time","<span style=\"color: #555\">token_time</span>")
  end
end
