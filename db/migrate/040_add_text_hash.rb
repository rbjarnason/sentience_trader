class AddTextHash < ActiveRecord::Migration
  def self.up
    add_column :classified_paragraphs, :text_hash, :string
    add_index :classified_paragraphs, [:text_hash]
  end

  def self.down
  end
end
