class AddId2 < ActiveRecord::Migration
  def self.up
    add_column :classified_paragraphs, :modified_by_user_id, :integer
  end

  def self.down
  end
end
