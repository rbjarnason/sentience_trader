# encoding: UTF-8

class ClassifiedPerson < ActiveRecord::Base  
  has_and_belongs_to_many :classified_paragraphs
  
  define_index do
    indexes person_name
    indexes position
    indexes organization_name
    
    set_property :delta => true
  end
  
  def copy_values!(person)
    puts person.person_type
    self.person_type = person.person_type if not self.person_type or (person.person_type and person.person_type.length>self.person_type.length) 
    self.person_nationality = person.person_nationality if not self.person_nationality or (person.person_nationality and person.person_nationality.length>self.person_nationality.length)
    self.position = person.position if not self.position or (person.position and person.position.length>self.position.length) 
    self.organization_type = person.organization_type if not self.organization_type or (person.organization_type and person.organization_type.length>self.organization_type.length) 
    self.organization_name = person.organization_name unless person.organization_name == "unknown-org" or person.organization_name == nil
    self.organization_nationality = person.organization_nationality if not self.organization_nationality or (person.organization_nationality and person.organization_nationality.length>self.organization_nationality.length) 
    self.save
  end

  def self.fuzzy_search(found_person)
    # If name fuzzy matches and one other field    
    # If position and organization matches
    # If only organization matches
  end

  def self.import_if_unique(quote)
    quote_person_name = Iconv.iconv('UTF-8//IGNORE//TRANSLIT', 'ASCII', quote[:person].name.downcase.strip)[0]
    person = ClassifiedPerson.new
    person.person_name = quote_person_name if quote_person_name
    person.person_type = quote[:person].persontype.downcase.strip if quote[:person].persontype 
    person.person_nationality = quote[:person].nationality.downcase.strip if quote[:person].nationality
    if quote[:person].positions[0]
      person.position = quote[:person].positions[0].name.downcase.strip if quote[:person].positions[0].name
    end
    if quote[:person].organizations[0]
      quote_organization_name = Iconv.iconv('UTF-8//IGNORE//TRANSLIT', 'ASCII', quote[:person].organizations[0].name.downcase.strip)[0]
      if quote_organization_name and quote_organization_name != "" and quote_organization_name.strip != "n/a"
        person.organization_name = quote_organization_name
      else
        person.organization_name = "unknown-org"
      end
      person.organization_type = quote[:person].organizations[0].organizationtype.downcase.strip if quote[:person].organizations[0].organizationtype
      person.organization_nationality = quote[:person].organizations[0].nationality.downcase.strip if quote[:person].organizations[0].nationality
    else
      person.organization_name = "unknown-org"
    end    
    puts "searching for quote_person_name: #{quote_person_name} quote_organization_name: #{quote_organization_name}"
    old_people = nil
    if quote_organization_name
      old_people = ClassifiedPerson.find(:all, :conditions=>["person_name = ? AND organization_name = ?", quote_person_name, quote_organization_name])
#      old_people = ClassifiedPerson.search :conditions=>{:person_name=>quote_person_name, 
#                                                         :organization_name=>quote_organization_name}
    end
    old_people = ClassifiedPerson.find(:all, :conditions=>["person_name = ? AND organization_name = ?", quote_person_name, "unknown-org"]) unless old_people and old_people.length>0

#    old_people = ClassifiedPerson.search :conditions=>{:person_name=>quote_person_name, 
#                                                       :organization_name=>"unknown-org"} unless old_people and old_people.length>0

    if old_people.length>0
      old_people[0].copy_values!(person)
      old_people[0]
    else
      person.save
      person
    end
  end
end
