class ChangeValid < ActiveRecord::Migration
  def self.up
    remove_column :classified_paragraphs, :valid
    add_column :classified_paragraphs, :junk, :boolean
  end

  def self.down
  end
end
