# encoding: UTF-8

class RssTarget < ActiveRecord::Base
  has_many :rss_items
end
