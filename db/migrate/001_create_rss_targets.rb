class CreateRssTargets < ActiveRecord::Migration
  def self.up
    create_table :rss_targets do |t|
      t.string :title
      t.string :url
      t.string :url_type
      t.integer :processing_time_interval
      t.datetime :last_processing_time
      t.boolean :active
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :rss_targets
  end
end
