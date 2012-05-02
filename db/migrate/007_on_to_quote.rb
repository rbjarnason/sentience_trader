class OnToQuote < ActiveRecord::Migration
  def self.up
    add_column :rss_items, :guid, :string
    add_index :rss_items, [:guid], :unique => true
  end

  def self.down
  end
end
