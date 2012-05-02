# encoding: UTF-8

require 'zlib'
require 'rubygems'
require 'stemmer'
require 'lingua/stemmer'

class ClassifiedParagraph < ActiveRecord::Base
  belongs_to :rss_item
  belongs_to :quote_target
  has_and_belongs_to_many :classified_people

  def self.get_paragraphs_to_train_for_classification_strategy(classification_strategy_id, limit=2)
    self.find_by_sql("SELECT * FROM classified_paragraphs\
                      WHERE NOT EXISTS (SELECT * FROM classification_strategies_classified_paragraphs \
                      WHERE classified_paragraphs.id = classification_strategies_classified_paragraphs.classified_paragraph_id \
                      AND classification_strategy_id=#{classification_strategy_id}) \
                      AND objective_subjective_score IS NOT NULL \
                      AND sentiment_score IS NOT NULL LIMIT #{limit};")
  end
  
  def self.count_paragraphs_to_train_for_classification_strategy(classification_strategy_id)
    self.count_by_sql("SELECT COUNT(*) FROM  classified_paragraphs WHERE NOT EXISTS (SELECT * FROM classification_strategies_classified_paragraphs \
                       WHERE classified_paragraphs.id = classification_strategies_classified_paragraphs.classified_paragraph_id \
                       AND classification_strategy_id=#{classification_strategy_id}) \
                       AND objective_subjective_score IS NOT NULL \
                       AND sentiment_score IS NOT NULL;")
  end

  def processed_text
    Zlib::Inflate.inflate(self.processed_compressed_text)
  end
  
  def original_text
    Zlib::Inflate.inflate(self.original_compressed_text)
  end

  def processed_texts_max_pre_post(max_pre_post=5)
    positions = []
    texts = []
    whole_text_a = processed_text.gsub(/[^a-z ]/, '').split
    #puts "WHOLE_TEXT: "+whole_text_a.inspect
    whole_text_a.each_with_index {|word,i| 
      positions << i if word.stem.index(ST_RATE_TARGET_TXT.stem)
    }
#    puts positions.inspect
    positions.each_with_index do |position,i|
      if i!=0
        startword = [0,position-max_pre_post, positions[i-1]+1].max
      else
        startword = [0,position-max_pre_post].max
      end
      if positions.length>i+1
        endword = [position+max_pre_post,whole_text_a.length-1,positions[i+1]-1].min
      else
        endword = [position+max_pre_post,whole_text_a.length-1].min
      end
#      puts "STARTWORD #{startword} ENDWORD: #{endword}"
      texts << whole_text_a[startword..endword]
    end
    texts
  end
  
  def stemmed_processed_texts(max_pre_post=5)
    s = Lingua::Stemmer.new
    texts = processed_texts_max_pre_post(max_pre_post)
    #puts "BEFORE: " + texts.inspect + " " + processed_text
    texts.each do |text| text.map!{|word| s.stem word} end
    #puts "AFTER: " + texts.inspect
    texts
#   map!{|word| word.stem} # slower but maybe slightly better
  end
  
  def get_sentiment_slider_value
    if self.sentiment_score
      case self.sentiment_score
        when -1.0 then 1
        when -0.5 then 2
        when 0.0 then 3
        when 0.5 then 4
        when 1.0 then 5
      end
    else
      3
    end
  end

  def set_sentiment_from_slider(value)
    self.sentiment_score = case value
        when 1 then -1.0
        when 2 then -0.5
        when 3 then 0.0
        when 4 then 0.5
        when 5 then 1.0
      end
  end

  def get_objective_slider_value
    if self.objective_subjective_score
      case self.objective_subjective_score
        when -1.0 then 1
        when -0.5 then 2
        when 0.5 then 4
        when 1.0 then 5
      end
    else
      2
    end
  end

  def set_objective_from_slider(value)
    self.objective_subjective_score = case value
        when 1 then -1.0
        when 2 then -0.5
        when 4 then 0.5
        when 5 then 1.0
      end
  end

  def import_and_save(source_type, rss_item_id, sequence_number, quote_target_id, paragraph_text, processed_paragraph_text, save)
    processed_paragraph_text = ParagraphTools.strip_numbers_and_dates(processed_paragraph_text)
    processed_paragraph_text = ParagraphTools.strip_various(processed_paragraph_text)      
    self.rss_item_id = rss_item_id
    self.sequence_number = sequence_number
    self.quote_target_id = quote_target_id      
    self.original_compressed_text=Zlib::Deflate.deflate(paragraph_text, Zlib::BEST_COMPRESSION)
    self.processed_compressed_text=Zlib::Deflate.deflate(processed_paragraph_text, Zlib::BEST_COMPRESSION)
    self.text_hash = Digest::SHA1.hexdigest(processed_paragraph_text.strip)
    self.source_type = source_type
    old = ClassifiedParagraph.find_by_text_hash(self.text_hash)
    self.copy_of_id = old.id if old
    self.save if save and not processed_paragraph_text.empty?
    processed_paragraph_text
  end
end
