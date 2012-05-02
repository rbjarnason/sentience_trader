class CreateNeuralPopulations < ActiveRecord::Migration
  def self.up
    create_table :neural_populations do |t|
      t.integer :max_generations
      t.integer :population_size
      t.float :best_fitness
      t.integer :current_generation, :default => 0
      t.text :population_data
      t.integer :quote_target_id
      t.boolean :complete, :default => false
      t.boolean :active, :default => false
      t.boolean :in_process, :default => false
      t.datetime :last_processing_start_time
      t.datetime :last_processing_stop_time
      t.timestamps
    end

    create_table :neural_populations_neural_strategies, :id => false do |t|
      t.column "neural_population_id" , :integer
      t.column "neural_strategy_id" , :integer
    end

    remove_column :neural_strategies, :hidden_neurons
    add_column :neural_strategies, :hidden_neurons_data, :text
    add_column :neural_strategies, :selected_inputs_data, :text
    add_column :neural_strategies, :inputs_scaling_data, :text
 
    add_column :neural_strategies, :desired_error, :float    
    add_column :neural_strategies, :last_processing_start_time, :datetime    
    add_column :neural_strategies, :last_processing_stop_time, :datetime    
  end

  def self.down
    drop_table :neural_populations
  end
end
