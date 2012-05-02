class AddWebPage < ActiveRecord::Migration
  def self.up
    create_table :processed_rss_items do |t|
      t.string :guid
      t.integer :quote_target_id
      t.timestamps
    end
    add_index :processed_rss_items, [:guid]
    add_index :processed_rss_items, [:quote_target_id]

    add_column :neural_strategies, :compressed_network, :binary, :size=> 10000000
    add_column :rss_items, :compressed_page, :binary, :size=> 512000
  end

  def self.down
  end
end
