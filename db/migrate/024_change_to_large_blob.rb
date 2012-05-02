class ChangeToLargeBlob < ActiveRecord::Migration
  def self.up
    remove_column :neural_populations, :population_data
    add_column :neural_populations, :population_data, :binary, :size=>4000000
  end

  def self.down
  end
end
