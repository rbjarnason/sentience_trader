class MoreBlob < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE neural_populations CHANGE COLUMN population_data population_data LONGBLOB"
  end

  def self.down
  end
end
