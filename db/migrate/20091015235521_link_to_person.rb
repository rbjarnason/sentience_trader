class LinkToPerson < ActiveRecord::Migration
  def self.up
    drop_table "classified_people_classified_paragraphs"
    create_table "classified_paragraphs_classified_people", :id => false, :force => true do |t|
      t.integer "classified_person_id"
      t.integer "classified_paragraph_id"
    end
  end

  def self.down
  end
end
