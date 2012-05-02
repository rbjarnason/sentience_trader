class RenameType < ActiveRecord::Migration
  def self.up
    rename_column :neural_strategies, :type, :network_type
  end

  def self.down
  end
end
