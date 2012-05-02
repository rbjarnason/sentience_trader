class AddCopyOf < ActiveRecord::Migration
  def self.up
    add_column :classified_paragraphs, :copy_of_id, :integer
  end

  def self.down
  end
end
