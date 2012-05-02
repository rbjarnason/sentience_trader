class AddPopulationProcess < ActiveRecord::Migration
  def self.up
    add_column :neural_strategies, :in_population_process, :boolean, :default => false
  end

  def self.down
  end
end
