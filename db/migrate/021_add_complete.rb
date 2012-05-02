class AddComplete < ActiveRecord::Migration
  def self.up
    add_column :neural_strategies, :complete, :boolean, :default => false
  end

  def self.down
  end
end
