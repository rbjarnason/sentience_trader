class OnlyTradingHours < ActiveRecord::Migration
  def self.up
    add_column :neural_strategies, :only_trading_hours, :boolean, :default => true
  end

  def self.down
  end
end
