class CreateClassificationStrategies < ActiveRecord::Migration
  def self.up
    create_table :classification_strategies do |t|
      t.string :title
      t.string :description
      t.binary :compressed_data_1, :size=> 500.megabytes
      t.binary :compressed_data_2, :size=> 500.megabytes
      t.binary :compressed_data_3, :size=> 500.megabytes
      t.timestamps
    end
    
    create_table "classification_strategies_classified_paragraphs", :id => false, :force => true do |t|
      t.integer :classification_strategy_id
      t.integer :classified_paragraph_id
    end
  end

  def self.down
    drop_table :classification_strategies
  end
end
