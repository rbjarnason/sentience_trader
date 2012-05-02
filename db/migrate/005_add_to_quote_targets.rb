class AddToQuoteTargets < ActiveRecord::Migration
  def self.up
    rename_column :quote_targets, :interval, :processing_time_interval
    add_column :quote_targets, :last_processing_time, :datetime
  end

  def self.down
  end
end
