class CreateClassifiedParagraphs < ActiveRecord::Migration
  def self.up
    create_table :classified_paragraphs do |t|
      t.integer :rss_item_id
      t.integer :parent_id
      t.boolean :valid, :default=>true
      t.binary :original_compressed_text, :size=> 512000
      t.binary :processed_compressed_text, :size=> 512000
      t.float :sentiment_score
      t.float :importance_score
      t.float :objective_subjective_score
      t.float :trusted_untrusted_score
      t.float :relevant_irrelevant_score

      t.timestamps
    end
        
    add_index :classified_paragraphs, [:rss_item_id]
    add_index :classified_paragraphs, [:parent_id]
    add_index :classified_paragraphs, [:valid]
  end

  def self.down
    drop_table :classified_paragraphs
  end
end
