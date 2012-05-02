class CreateClassifiedPersonCategories < ActiveRecord::Migration
  def self.up
    create_table :classified_person_categories do |t|
      t.string :name
      t.timestamps
    end
    
    add_column :classified_people, :classified_person_category_id, :integer
    
    right = Right.create :name => "classified_person_categories All",
                     :controller => "classified_person_categories",
                     :action => "*"
    right.save  
    adminrole = Role.find_by_name("Admin")
    adminrole.rights << right
  end

  def self.down
    drop_table :classified_person_categories
  end
end
