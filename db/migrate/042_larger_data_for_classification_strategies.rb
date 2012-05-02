class LargerDataForClassificationStrategies < ActiveRecord::Migration
  def self.up
    change_column :classification_strategies, :compressed_data_1, :binary, :limit => 500.megabyte
    change_column :classification_strategies, :compressed_data_2, :binary, :limit => 500.megabyte
    change_column :classification_strategies, :compressed_data_3, :binary, :limit => 500.megabyte
  end

  def self.down
  end
end
