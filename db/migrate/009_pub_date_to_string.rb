class PubDateToString < ActiveRecord::Migration
  def self.up
    remove_column :rss_items, :pubDate
    add_column :rss_items, :pubDate, :string
  end

  def self.down
  end
end
