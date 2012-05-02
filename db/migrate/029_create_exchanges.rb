class CreateExchanges < ActiveRecord::Migration
  def self.up
    create_table :exchanges do |t|
      t.string :name
      t.string :symbol_data_url
      t.string :symbol_data_format
      t.boolean :active
      t.timestamps
    end
    add_column :quote_targets, :exchange_id, :integer
    add_column :quote_targets, :yahoo_quote_enabled, :boolean
    add_column :quote_targets, :last_yahoo_processing_time, :datetime
    QuoteTarget.find(:all).each do |q|
      q.yahoo_quote_enabled = true
      q.save
    end
  end

  def self.down
    drop_table :exchanges
  end
end
