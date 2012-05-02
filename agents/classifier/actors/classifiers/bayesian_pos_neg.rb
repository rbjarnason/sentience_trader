require 'classifier'

BAY_POS_NEG_MAX_TARGET_WORD_PRE_POST = 40

class BayesianPosNeg

  def train(strategy)
    unless strategy.compressed_data_1
      bayesian = Classifier::Bayes.new 'negative', 'neutral', 'positive'
    else
      bayesian = Marshal.load(Zlib::Inflate.inflate(strategy.compressed_data_1))
    end
    
    n =  ClassifiedParagraph.count_paragraphs_to_train_for_classification_strategy(strategy.id)
    number_to_classify = (n/8)*7.0
    number_to_validate = (n/8)*1.0
    
    if n>500
      puts "Train Pos Neg Bayesian #{number_to_classify} entries"
      paragraphs = ClassifiedParagraph.get_paragraphs_to_train_for_classification_strategy(strategy.id, [number_to_classify.to_i,1].max)
      paragraphs.each do |paragraph|
        paragraph.processed_texts_max_pre_post(BAY_POS_NEG_MAX_TARGET_WORD_PRE_POST).each_with_index do |p,i|                
          #puts "#{i} "+p.inspect+" "+p.join(" ")
        end
        case paragraph.sentiment_score
          when -2.0..-0.1 then
            paragraph.processed_texts_max_pre_post(BAY_POS_NEG_MAX_TARGET_WORD_PRE_POST).each do |p|                
              bayesian.train_negative p.join(" ")
            end
          when 0.0 then
            paragraph.processed_texts_max_pre_post(BAY_POS_NEG_MAX_TARGET_WORD_PRE_POST).each do |p|                
              bayesian.train_neutral p.join(" ")
            end
          when 0.1..2.0 then
            paragraph.processed_texts_max_pre_post(BAY_POS_NEG_MAX_TARGET_WORD_PRE_POST).each do |p|                
              bayesian.train_positive p.join(" ")
            end
        end
        strategy.classified_paragraphs << paragraph
      end
  
      strategy.compressed_data_1 = Zlib::Deflate.deflate(Marshal.dump(bayesian))
    else
      puts "Less then 500 for Bayesian"
      number_to_validate =  ClassifiedParagraph.count_paragraphs_to_train_for_classification_strategy(strategy.id)
    end

    validate(strategy, bayesian, number_to_validate)

    strategy.save
    puts strategy.inspect
  end
    
  def validate(strategy, classifier, number_to_validate)
    puts "validating #{number_to_validate}"
    paragraphs = ClassifiedParagraph.get_paragraphs_to_train_for_classification_strategy(strategy.id, [number_to_validate.to_i,1].max)
    
    negative_correct = neutral_correct = positive_correct = 0
    negative_wrong = neutral_wrong = positive_wrong = 0
    correct = wrong = 0
    
    paragraphs.each do |paragraph|
      if paragraph.processed_texts_max_pre_post(BAY_POS_NEG_MAX_TARGET_WORD_PRE_POST)[0]
        puts "validating: #{paragraph.processed_texts_max_pre_post(BAY_POS_NEG_MAX_TARGET_WORD_PRE_POST)[0].join(" ")}"
        result = classifier.classify paragraph.processed_texts_max_pre_post(BAY_POS_NEG_MAX_TARGET_WORD_PRE_POST)[0].join(" ")
        puts "result: #{result}"
        case paragraph.sentiment_score
          when -2.0..-0.1 then
            if result == "Negative"
              negative_correct+=1
              correct+=1
            else
              negative_wrong+=1
              wrong+=1
            end
          when 0.0 then
            if result == "Neutral"
              neutral_correct+=1
              correct+=1
            else
              neutral_wrong+=1
              wrong+=1
            end
          when 0.1..2.0 then
            if result == "Positive"
              positive_correct+=1
              correct+=1
            else
              positive_wrong+=1
              wrong+=1
            end
        end  
      end
    end
  
    correct_p = (correct.to_f/number_to_validate.to_f)*100.0
    puts "correct: #{correct} #{correct_p}%"
    puts "wrong #{wrong} #{(wrong.to_f/number_to_validate.to_f)*100.0}%"

    puts "negative_correct: #{negative_correct}"
    puts "neutral_correct: #{neutral_correct}"
    puts "positive_correct: #{positive_correct}"

    puts "negative_wrong #{negative_wrong}"
    puts "neutral_wrong #{neutral_wrong}"
    puts "positive_wrong #{positive_wrong}"
  end
end
