class CreatePredictions < ActiveRecord::Migration
  def self.up
    create_table :predictions do |t|
      t.integer :neuron_strategy_id
      t.float :float_value
      t.float :error_value
      t.timestamps
    end
    add_column :neural_strategies, :processing_time_interval, :integer, :default => 1800
    add_column :neural_strategies, :last_neural_processing_time, :datetime
    add_column :neural_strategies, :last_prediction_processing_time, :datetime
  end

  def self.down
    drop_table :predictions
  end
end
