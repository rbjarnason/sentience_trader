require 'calais'

class Entity
  attr_accessor :calais_id, :name
  @@entities = []
  
  def initialize
    @@entities << self
  end
  
  def self.dump_entities
    @@entities
  end
  
  def self.find(search_id)
    puts "in find with id: #{search_id}"
    puts @@entities.inspect
    found_entity = nil
    @@entities.each do |e|
      found_entity = e if e.calais_id==search_id
    end
    puts found_entity.inspect
    found_entity
  end
  
  def import_attributes(calais_id, attributes)
    attributes.each do |a|
      self.send(a[0]+"=",a[1])
    end
    self.calais_id = calais_id
  end
end

class EntityOrganization < Entity
  attr_accessor :organizationtype, :nationality

  def initialize
    @persons = []
    super
  end

  def add_person(person)
    @persons << person
  end
  
end

class EntityPosition < Entity
end

class EntityPerson < Entity
  attr_accessor :persontype, :nationality, :positions, :organizations

  def initialize
    @positions = []
    @organizations = []
    super
  end

  def add_organization(org)
    @organizations << org
  end

  def add_position(pos)
    @positions << pos unless @positions.index(pos)
  end
end

class CalaisTools
  def self.calais_quotes(content)
    raw = Calais.process_document(
      :content => content,
      :content_type => :text, 
      :license_id => 'upnr5jjhw6nj78n6rsnmju29'
     )
     
     quotes = []
     raw.entities.each do |e|
       puts e.inspect
       if e.type == "Person"
         entity = EntityPerson.new
         entity.import_attributes(e.calais_hash.value, e.attributes)
       elsif e.type == "Position"
         entity = EntityPosition.new
         entity.import_attributes(e.calais_hash.value, e.attributes)
       elsif e.type == "Organization"
         entity = EntityOrganization.new
         entity.import_attributes(e.calais_hash.value, e.attributes)
       elsif e.type == "Company"
         entity = EntityOrganization.new
         entity.import_attributes(e.calais_hash.value, e.attributes)
       end
     end
     raw.relations.each do |r|
       puts r.type
       puts r.inspect
       if r.type == "Quotation"
         person = Entity.find(r.attributes["person"].value) if r.attributes["person"]
         quotes << {:person=>person, :quote=>r.attributes["quote"], :offset=>r.instances[0].offset}
       elsif r.type == "PersonCareer"
         position = Entity.find(r.attributes["position"].value) if r.attributes["position"]
         person = Entity.find(r.attributes["person"].value) if r.attributes["person"]
         organization = Entity.find(r.attributes["organization"].value) if r.attributes["organization"]
         organization = Entity.find(r.attributes["company"].value) if r.attributes["company"]
         person.add_position(position) if position
         person.add_organization(organization) if organization
         organization.add_person(person) if organization and person
       end
     end
     quotes
  end
end
