class MoreToQuote < ActiveRecord::Migration
  def self.up
    rename_column :quote_targets, :search_string, :search_strings
  end

  def self.down
  end
end
