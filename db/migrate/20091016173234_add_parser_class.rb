class AddParserClass < ActiveRecord::Migration
  def self.up
    add_column :rss_targets, :parser, :string
  end

  def self.down
  end
end
