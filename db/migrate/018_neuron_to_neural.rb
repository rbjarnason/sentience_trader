class NeuronToNeural < ActiveRecord::Migration
  def self.up
    rename_column :predictions, :neuron_strategy_id, :neural_strategy_id
  end

  def self.down
  end
end
