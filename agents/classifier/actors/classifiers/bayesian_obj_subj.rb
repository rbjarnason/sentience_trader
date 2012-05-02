require 'classifier'

BAY_OBJ_SUBJ_MAX_TARGET_WORD_PRE_POST = 40

class BayesianObjSubj

  def train(strategy)
    unless strategy.compressed_data_1
      bayesian = Classifier::Bayes.new 'objective', 'subjective'
    else
      bayesian = Marshal.load(Zlib::Inflate.inflate(strategy.compressed_data_1))
    end
    
    n =  ClassifiedParagraph.count_paragraphs_to_train_for_classification_strategy(strategy.id)
    number_to_classify = (n/8)*7.0
    number_to_validate = (n/8)*1.0
    
    if n>500
      puts "Train Obj Subj Bayesian #{number_to_classify} entries"
      paragraphs = ClassifiedParagraph.get_paragraphs_to_train_for_classification_strategy(strategy.id, [number_to_classify.to_i,1].max)
      paragraphs.each do |paragraph|
        paragraph.processed_texts_max_pre_post(BAY_OBJ_SUBJ_MAX_TARGET_WORD_PRE_POST).each_with_index do |p,i|                
          puts "#{i} "+p.inspect+" "+p.join(" ")
        end
        case paragraph.objective_subjective_score
          when -2.0..-0.1
            paragraph.processed_texts_max_pre_post(BAY_OBJ_SUBJ_MAX_TARGET_WORD_PRE_POST).each do |p|                
              bayesian.train_objective p.join(" ")
            end
          when 0.1..2.0
            paragraph.processed_texts_max_pre_post(BAY_OBJ_SUBJ_MAX_TARGET_WORD_PRE_POST).each do |p|                
              bayesian.train_subjective p.join(" ")
            end
        end
        strategy.classified_paragraphs << paragraph
      end
  
      strategy.compressed_data_1 = Zlib::Deflate.deflate(Marshal.dump(bayesian))
    else
      puts "Less then 500 for Bayesian Obj Subj"
      number_to_validate =  ClassifiedParagraph.count_paragraphs_to_train_for_classification_strategy(strategy.id)
    end

    validate(strategy, bayesian, number_to_validate)

    strategy.save
    puts strategy.inspect
  end
    
  def validate(strategy, classifier, number_to_validate)
    puts "validating #{number_to_validate}"
    paragraphs = ClassifiedParagraph.get_paragraphs_to_train_for_classification_strategy(strategy.id, [number_to_validate.to_i,1].max)
    
    objective_correct = subjective_correct = 0
    objective_wrong = subjective_wrong = 0
    correct = wrong = 0
    
    paragraphs.each do |paragraph|
      if paragraph.processed_texts_max_pre_post(BAY_OBJ_SUBJ_MAX_TARGET_WORD_PRE_POST)[0]
        puts "validating: #{paragraph.processed_texts_max_pre_post(BAY_OBJ_SUBJ_MAX_TARGET_WORD_PRE_POST)[0].join(" ")}"
        result = classifier.classify paragraph.processed_texts_max_pre_post(BAY_OBJ_SUBJ_MAX_TARGET_WORD_PRE_POST)[0].join(" ")
        puts "result: #{result}"
        case paragraph.objective_subjective_score
          when -2.0..-0.1
            if result == "Objective"
              objective_correct+=1
              correct+=1
            else
              objective_wrong+=1
              wrong+=1
            end
          when 0.1..2.0 then
            if result == "Subjective"
              subjective_correct+=1
              correct+=1
            else
              subjective_wrong+=1
              wrong+=1
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

    puts "objective_correct: #{objective_correct}"
    puts "subjective_correct: #{subjective_correct}"

    puts "objective_wrong #{objective_wrong}"
    puts "subjective_wrong #{subjective_wrong}"
  end
end
