class AddDouble < ActiveRecord::Migration
  def self.up
    add_column :predictions, :double_value, :double
  end

  def self.down
  end
end
