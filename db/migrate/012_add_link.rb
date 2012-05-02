class AddLink < ActiveRecord::Migration
  def self.up
    add_index :rss_items, [:guid], :unique => true

    create_table :quote_targets_rss_items, :id => false do |t|
      t.column "quote_target_id" , :integer
      t.column "rss_item_id" , :integer
    end
  end

  def self.down
  end
end
