class AddClassifiedPerson < ActiveRecord::Migration
  def self.up
   create_table :classified_people do |t|
      t.string :person_name
      t.string :person_type
      t.string :person_nationality
      t.string :position
      t.string :organization_name
      t.string :organization_type
      t.string :organization_nationality
      t.timestamps
    end
    
    right = Right.create :name => "classified_people All",
                         :controller => "classified_people",
                         :action => "*"
    right.save  
    adminrole = Role.find_by_name("Admin")
    adminrole.rights << right
  end

  def self.down
  end
end
