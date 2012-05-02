class AddCalaisFlag < ActiveRecord::Migration
  def self.up
    add_column :rss_items, :has_processed_calais, :boolean, :default=>false
  end

  def self.down
  end
end
