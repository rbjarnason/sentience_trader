class CreateNeuralStrategies < ActiveRecord::Migration
  def self.up
    create_table :neural_strategies do |t|
      t.string :title
      t.boolean :active, :default => false
      t.datetime :last_work_unit_time
      t.integer :max_epochs
      t.text :network
      t.string :type
      t.string :time_span_type
      t.string :hidden_neurons
      t.boolean :in_process, :default => false
      t.boolean :error_flag, :default => false
      t.integer :quote_target_id
      t.timestamps
    end
  end

  def self.down
    drop_table :neural_strategies
  end
end
