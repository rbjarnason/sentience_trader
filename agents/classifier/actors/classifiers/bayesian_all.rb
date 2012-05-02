require 'classifier'

BAY_MAX_TARGET_WORD_PRE_POST = 40

class BayesianAll

  def train(strategy)
    unless strategy.compressed_data_1
      bayesian = Classifier::Bayes.new 'objective_negative', 'objective_neutral', 'objective_positive',
                                       'subjective_negative', 'subjective_neutral', 'subjective_positive'
    else
      bayesian = Marshal.load(Zlib::Inflate.inflate(strategy.compressed_data_1))
    end
    
    n =  ClassifiedParagraph.count_paragraphs_to_train_for_classification_strategy(strategy.id)
    number_to_classify = (n/8)*7.0
    number_to_validate = (n/8)*1.0
    
    if n>500
      puts "Train All Bayesian #{number_to_classify} entries"
      paragraphs = ClassifiedParagraph.get_paragraphs_to_train_for_classification_strategy(strategy.id, [number_to_classify.to_i,1].max)
      paragraphs.each do |paragraph|
        paragraph.processed_texts_max_pre_post(BAY_MAX_TARGET_WORD_PRE_POST).each_with_index do |p,i|                
          #puts "#{i} "+p.inspect+" "+p.join(" ")
        end
        case paragraph.objective_subjective_score
          when -2.0..-0.1
            case paragraph.sentiment_score
              when -2.0..-0.1 then
                paragraph.processed_texts_max_pre_post(BAY_MAX_TARGET_WORD_PRE_POST).each do |p|                
                  bayesian.train_objective_negative p.join(" ")
                end
              when 0.0 then
                paragraph.processed_texts_max_pre_post(BAY_MAX_TARGET_WORD_PRE_POST).each do |p|                
                  bayesian.train_objective_neutral p.join(" ")
                end
              when 0.1..2.0 then
                paragraph.processed_texts_max_pre_post(BAY_MAX_TARGET_WORD_PRE_POST).each do |p|                
                  bayesian.train_objective_positive p.join(" ")
                end
            end
          when 0.1..2.0
            case paragraph.sentiment_score
              when -2.0..-0.1 then
                paragraph.processed_texts_max_pre_post(BAY_MAX_TARGET_WORD_PRE_POST).each do |p|                
                  bayesian.train_subjective_negative p.join(" ")
                end
              when 0.0 then
                paragraph.processed_texts_max_pre_post(BAY_MAX_TARGET_WORD_PRE_POST).each do |p|                
                  bayesian.train_subjective_neutral p.join(" ")
                end
              when 0.1..2.0 then
                paragraph.processed_texts_max_pre_post(BAY_MAX_TARGET_WORD_PRE_POST).each do |p|                
                  bayesian.train_subjective_positive p.join(" ")
                end
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
    
    objective_negative_correct = objective_neutral_correct = objective_positive_correct = subjective_negative_correct = subjective_neutral_correct = subjective_positive_correct = 0
    objective_negative_wrong = objective_neutral_wrong = objective_positive_wrong = subjective_negative_wrong = subjective_neutral_wrong = subjective_positive_wrong = 0
    correct = wrong = 0
    
    paragraphs.each do |paragraph|
      if paragraph.processed_texts_max_pre_post(BAY_MAX_TARGET_WORD_PRE_POST)[0]
        puts "validating: #{paragraph.processed_texts_max_pre_post(BAY_MAX_TARGET_WORD_PRE_POST)[0].join(" ")}"
        result = classifier.classify paragraph.processed_texts_max_pre_post(BAY_MAX_TARGET_WORD_PRE_POST)[0].join(" ")
        puts "result: #{result}"
        case paragraph.objective_subjective_score
          when -2.0..-0.1
            case paragraph.sentiment_score
              when -2.0..-0.1 then
                if result == "Objective negative"
                  objective_negative_correct+=1
                  correct+=1
                else
                  objective_negative_wrong+=1
                  wrong+=1
                end
              when 0.0 then
                if result == "Objective neutral"
                  objective_neutral_correct+=1
                  correct+=1
                else
                  objective_neutral_wrong+=1
                  wrong+=1
                end
              when 0.1..2.0 then
                if result == "Objective positive"
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
                if result == "Subjective negative"
                  subjective_negative_correct+=1
                  correct+=1
                else
                  subjective_negative_wrong+=1
                  wrong+=1
                end
              when 0.0 then
                if result == "Subjective neutral"
                  subjective_neutral_correct+=1
                  correct+=1
                else
                  subjective_neutral_wrong+=1
                  wrong+=1
                end
              when 0.1..2.0 then
                if result == "Subjective positive"
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
