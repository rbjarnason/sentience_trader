class AddLastTrade < ActiveRecord::Migration
  def self.up
    add_column :predictions, :last_trade, :float
  end

  def self.down
  end
end
