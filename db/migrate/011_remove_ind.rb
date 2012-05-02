class RemoveInd < ActiveRecord::Migration
  def self.up
    remove_index :rss_items, [:guid]
  end

  def self.down
  end
end
