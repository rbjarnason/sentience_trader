# encoding: UTF-8

class ProcessedRssItem < ActiveRecord::Base

  def setup(guid,quote_target_id)
    self.guid = guid
    self.quote_target_id = quote_target_id
  end

end
