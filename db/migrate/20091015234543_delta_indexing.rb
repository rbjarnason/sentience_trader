class DeltaIndexing < ActiveRecord::Migration
  def self.up
    add_column :classified_people, :delta, :boolean, :default => true, :null => false
    
    create_table "classified_people_classified_paragraphs", :id => false, :force => true do |t|
      t.integer "classified_person_id"
      t.integer "rss_item_id"
    end
  end

  def self.down
  end
end
