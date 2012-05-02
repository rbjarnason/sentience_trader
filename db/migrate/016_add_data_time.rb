class AddDataTime < ActiveRecord::Migration
  def self.up
    add_column :predictions, :data_time, :datetime
  end

  def self.down
  end
end
