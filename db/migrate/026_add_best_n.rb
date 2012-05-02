class AddBestN < ActiveRecord::Migration
  def self.up
    add_column :neural_populations, :best_neural_strategy_id, :integer
  end

  def self.down
  end
end
