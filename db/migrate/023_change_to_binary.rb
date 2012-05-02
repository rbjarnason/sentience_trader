class ChangeToBinary < ActiveRecord::Migration
  def self.up
    remove_column :neural_strategies, :hidden_neurons_data
    remove_column :neural_strategies, :selected_inputs_data
    remove_column :neural_strategies, :inputs_scaling_data
    remove_column :neural_populations, :population_data
    add_column :neural_strategies, :hidden_neurons_data, :binary
    add_column :neural_strategies, :selected_inputs_data, :binary
    add_column :neural_strategies, :inputs_scaling_data, :binary
    add_column :neural_populations, :population_data, :binary
    add_column :neural_populations, :network_type, :string
    add_column :neural_populations, :time_span_type, :string
  end

  def self.down
  end
end
