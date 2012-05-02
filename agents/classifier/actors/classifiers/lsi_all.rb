require 'classifier'

LSI_MAX_TARGET_WORD_PRE_POST = 40

class LsiAll

  def train(strategy)
    unless strategy.compressed_data_1
      lsi = Classifier::LSI.new
    else
      lsi = Marshal.load(Zlib::Inflate.inflate(strategy.compressed_data_1))
    end
    
    n =  ClassifiedParagraph.count_paragraphs_to_train_for_classification_strategy(strategy.id)
    number_to_classify = (n/8)*7.0
    number_to_validate = (n/8)*1.0
    
    if n>500
      pc = 0
      puts "Train LSI #{number_to_classify} entries"
      paragraphs = ClassifiedParagraph.get_paragraphs_to_train_for_classification_strategy(strategy.id, [number_to_classify.to_i,1].max)
      paragraphs.each do |paragraph|
        puts "#{pc+=1}/#{number_to_classify}"
        case paragraph.objective_subjective_score
          when -2.0..-0.1
            case paragraph.sentiment_score
              when -2.0..-0.1 then
                paragraph.processed_texts_max_pre_post(LSI_MAX_TARGET_WORD_PRE_POST).each do |p|                
                  lsi.add_item  p.join(" "), :objective_negative 
                end
              when 0.0 then
                paragraph.processed_texts_max_pre_post(LSI_MAX_TARGET_WORD_PRE_POST).each do |p|                
                  lsi.add_item  p.join(" "), :objective_neutral 
                end
              when 0.1..2.0 then
                paragraph.processed_texts_max_pre_post(LSI_MAX_TARGET_WORD_PRE_POST).each do |p|                
                  lsi.add_item  p.join(" "), :objective_positive 
                end
            end
          when 0.1..2.0
            case paragraph.sentiment_score
              when -2.0..-0.1 then
                paragraph.processed_texts_max_pre_post(LSI_MAX_TARGET_WORD_PRE_POST).each do |p|                
                  lsi.add_item  p.join(" "), :subjective_negative 
                end
              when 0.0 then
                paragraph.processed_texts_max_pre_post(LSI_MAX_TARGET_WORD_PRE_POST).each do |p|                
                  lsi.add_item  p.join(" "), :subjective_neutral 
                end
              when 0.1..2.0 then
                paragraph.processed_texts_max_pre_post(LSI_MAX_TARGET_WORD_PRE_POST).each do |p|                
                  lsi.add_item  p.join(" "), :subjective_positive 
                end
            end
        end
        strategy.classified_paragraphs << paragraph
      end
    else
      puts "Less then 500 for LSI"
      number_to_validate =  ClassifiedParagraph.count_paragraphs_to_train_for_classification_strategy(strategy.id)
    end

    strategy.compressed_data_1 = Zlib::Deflate.deflate(Marshal.dump(lsi))

    validate(strategy, lsi, number_to_validate)

 #   strategy.save
    #puts strategy.inspect
  end
    
  def validate(strategy, classifier, number_to_validate)
    puts "validating #{number_to_validate}"
    paragraphs = ClassifiedParagraph.get_paragraphs_to_train_for_classification_strategy(strategy.id, [number_to_validate.to_i,1].max)
    
    objective_negative_correct = objective_neutral_correct = objective_positive_correct = subjective_negative_correct = subjective_neutral_correct = subjective_positive_correct = 0
    objective_negative_wrong = objective_neutral_wrong = objective_positive_wrong = subjective_negative_wrong = subjective_neutral_wrong = subjective_positive_wrong = 0
    correct = wrong = 0
    
    paragraphs.each do |paragraph|
      if paragraph.processed_texts_max_pre_post(LSI_MAX_TARGET_WORD_PRE_POST)[0]
        puts "validating: #{paragraph.processed_texts_max_pre_post(LSI_MAX_TARGET_WORD_PRE_POST)[0].join(" ")}"
        result = classifier.classify paragraph.processed_texts_max_pre_post(LSI_MAX_TARGET_WORD_PRE_POST)[0].join(" ")
        puts "result: #{result}"
        case paragraph.objective_subjective_score
          when -2.0..-0.1
            case paragraph.sentiment_score
              when -2.0..-0.1 then
                if result == :objective_negative
                  objective_negative_correct+=1
                  correct+=1
                else
                  objective_negative_wrong+=1
                  wrong+=1
                end
              when 0.0 then
                if result == :objective_neutral
                  objective_neutral_correct+=1
                  correct+=1
                else
                  objective_neutral_wrong+=1
                  wrong+=1
                end
              when 0.1..2.0 then
                if result == :objective_positive
                  objective_positive_correct+=1
                  correct+=1
                else
                  objective_positive_wrong+=1
                  wrong+=1
                end
            end  
          when 0.1..2.0 then
            case paragraph.sentiment_score
              when -2.0..-0.1 then
                if result == :subjective_negative
                  subjective_negative_correct+=1
                  correct+=1
                else
                  subjective_negative_wrong+=1
                  wrong+=1
                end
              when 0.0 then
                if result == :subjective_neutral
                  subjective_neutral_correct+=1
                  correct+=1
                else
                  subjective_neutral_wrong+=1
                  wrong+=1
                end
              when 0.1..2.0 then
                if result == :subjective_positive
                  subjective_positive_correct+=1
                  correct+=1
                else
                  subjective_positive_wrong+=1
                  wrong+=1
                end
            end
          else
            number_to_validate-=1
  #          puts "ERROR for score: #{paragraph.objective_subjective_score} text: #{paragraph.processed_text}"
        end
      end
    end
  
    correct_p = (correct.to_f/number_to_validate.to_f)*100.0
    puts "correct: #{correct} #{correct_p}%"
    puts "wrong #{wrong} #{(wrong.to_f/number_to_validate.to_f)*100.0}%"

    puts "objective_negative_correct: #{objective_negative_correct}"
    puts "objective_neutral_correct: #{objective_neutral_correct}"
    puts "objective_positive_correct: #{objective_positive_correct}"
    puts "subjective_negative_correct: #{subjective_negative_correct}"
    puts "subjective_neutral_correct: #{subjective_neutral_correct}"
    puts "subjective_positive_correct: #{subjective_positive_correct}"

    puts "objective_negative_wrong #{objective_negative_wrong}"
    puts "objective_neutral_wrong #{objective_neutral_wrong}"
    puts "objective_positive_wrong #{objective_positive_wrong}"
    puts "subjective_negative_wrong #{subjective_negative_wrong}"
    puts "subjective_neutral_wrong #{subjective_neutral_wrong}"
    puts "subjective_positive_wrong #{subjective_positive_wrong}"
  end
end
