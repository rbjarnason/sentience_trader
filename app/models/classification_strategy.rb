# encoding: UTF-8

class ClassificationStrategy < ActiveRecord::Base
  has_and_belongs_to_many :classified_paragraphs  
end
