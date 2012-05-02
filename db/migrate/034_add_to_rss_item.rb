class AddToRssItem < ActiveRecord::Migration
  def self.up
    add_column :rss_items, :has_been_scored, :boolean, :default=>false
    add_column :rss_items, :has_created_paragraphs, :boolean, :default=>false
    add_column :rss_items, :last_scored_at, :datetime
    add_column :classified_paragraphs, :source_type, :integer
  end

  def self.down
  end
end
