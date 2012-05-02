class CreateQuoteValues < ActiveRecord::Migration
  def self.up
    create_table :quote_values do |t|
      t.integer :quote_target_id
      t.datetime :data_time
      t.float :price
      t.float :change
      t.integer :volume
      t.float :today_open
      t.float :previous_close
      t.float :intraday_high
      t.float :intraday_low
      t.float :year_high
      t.float :year_low
      t.timestamps
    end
  end

  def self.down
    drop_table :quote_values
  end
end
