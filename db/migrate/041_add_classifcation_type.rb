class AddClassifcationType < ActiveRecord::Migration
  def self.up
    add_column :classification_strategies, :classification_type, :string
  end

  def self.down
  end
end
