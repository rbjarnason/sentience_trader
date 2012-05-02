class DescToText < ActiveRecord::Migration
  def self.up
    remove_column :rss_items, :description
    add_column :rss_items, :description, :text
  end

  def self.down
  end
end
