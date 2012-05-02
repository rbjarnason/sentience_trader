class CreateQuoteTargets < ActiveRecord::Migration
  def self.up
    create_table :quote_targets do |t|
      t.string :symbol
      t.string :search_string
      t.integer :interval
      t.boolean :active
      t.timestamps
    end
  end

  def self.down
    drop_table :quote_targets
  end
end
