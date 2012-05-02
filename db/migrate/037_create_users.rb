require 'digest/sha1'

class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email
      t.string :hashed_password
      t.string :salt
      t.string :first_name
      t.string :last_name

      t.timestamps
    end

    create_table "rights", :force => true do |t|
      t.column "name",       :string
      t.column "controller", :string
      t.column "action",     :string
    end
  
    create_table "rights_roles", :id => false, :force => true do |t|
      t.column "right_id", :integer
      t.column "role_id",  :integer
    end
  
    create_table "roles", :force => true do |t|
      t.column "name", :string
    end
  
    create_table "roles_users", :id => false, :force => true do |t|
      t.column "role_id", :integer
      t.column "user_id", :integer
    end
   
    adminrole = Role.create :name => "Admin"

    adminuser = User.create :email => "admin",
                            :email_confirmation => "admin",
                            :password => "rvb12345",
                            :password_confirmation => "rvb12345",
                            :password_confirmation => "rvb12345",
                            :first_name => "admin",
                            :last_name => "admin"
    
    adminuser.roles << adminrole
 
    if adminuser.save
      puts "save user complete"
    else
      puts "save user FAILED"
    end

    puts adminuser.to_s

    users_all_rights = Right.create :name => "Users All",
                                     :controller => "users",
                                     :action => "*"
    users_all_rights.save

    classification_strategies = Right.create :name => "classification_strategies All",
                                        :controller => "classification_strategies",
                                        :action => "*"
    classification_strategies.save

    classified_paragraphs = Right.create :name => "classified_paragraphs All",
                                    :controller => "classified_paragraphs",
                                    :action => "*"
    classified_paragraphs.save

    exchanges = Right.create :name => "exchanges All",
                                     :controller => "exchanges",
                                     :action => "*"
    exchanges.save
    
    neural_populations = Right.create :name => "neural_populations States All",
                                     :controller => "neural_populations",
                                     :action => "*"
    neural_populations.save

    neural_strategies = Right.create :name => "neural_strategies Types All",
                                     :controller => "neural_strategies",
                                     :action => "*"
    neural_strategies.save 


    predictions = Right.create :name => "predictions All",
                                     :controller => "predictions",
                                     :action => "*"
    predictions.save
    
    quote_targets = Right.create :name => "quote_targets States All",
                                     :controller => "quote_targets",
                                     :action => "*"
    quote_targets.save

    quote_values = Right.create :name => "quote_values Types All",
                                     :controller => "quote_values",
                                     :action => "*"
    quote_values.save 

    rss_items = Right.create :name => "rss_items All",
                                     :controller => "rss_items",
                                     :action => "*"
    rss_items.save
    
    rss_item_scores = Right.create :name => "rss_item_scores States All",
                                     :controller => "rss_item_scores",
                                     :action => "*"
    rss_item_scores.save

    rss_targets = Right.create :name => "rss_targets Types All",
                                     :controller => "rss_targets",
                                     :action => "*"
    rss_targets.save  
                
    adminrole.rights << users_all_rights
    adminrole.rights << classification_strategies
    adminrole.rights << classified_paragraphs
    adminrole.rights << exchanges
    adminrole.rights << neural_populations
    adminrole.rights << neural_strategies
    adminrole.rights << predictions
    adminrole.rights << quote_targets
    adminrole.rights << quote_values
    adminrole.rights << rss_items
    adminrole.rights << rss_item_scores
    adminrole.rights << rss_targets
    adminrole.save
  end

  def self.down
    drop_table :users
  end
end
