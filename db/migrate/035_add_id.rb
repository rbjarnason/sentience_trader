class AddId < ActiveRecord::Migration
  def self.up
    add_column :rss_item_scores, :quote_target_id, :integer
    add_column :classified_paragraphs, :quote_target_id, :integer
    add_column :classified_paragraphs, :sequence_number, :integer
  end

  def self.down
  end
end
