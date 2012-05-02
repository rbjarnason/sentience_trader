class CreateRssItems < ActiveRecord::Migration
  def self.up
    create_table :rss_items do |t|
      t.string :title
      t.binary :description
      t.string :link
      t.string :language
      t.string :copyright
      t.datetime :pubDate
      t.boolean :compressed
      t.integer :rss_target_id
      t.timestamps
    end
  end

  def self.down
    drop_table :rss_items
  end
end
