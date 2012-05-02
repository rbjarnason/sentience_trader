class CreateRssItemScores < ActiveRecord::Migration
  def self.up
    create_table :rss_item_scores do |t|
      t.integer :rss_item_id
      t.integer :classification_strategy_id
      t.float :sentiment_score
      t.float :objective_subjective_score
      t.float :average_sentiment_score
      t.float :average_importance_score
      t.float :average_objective_subjective_score
      t.float :average_trusted_untrusted_score
      t.float :average_relevant_irrelevant_score

      t.timestamps
    end
 
    add_index :rss_item_scores, [:rss_item_id]
    add_index :rss_item_scores, [:classification_strategy_id]
  end

  def self.down
    drop_table :rss_item_scores
  end
end
