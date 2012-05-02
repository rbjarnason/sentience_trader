require 'ruby_fann/neural_network'
require 'ruby_fann/neurotica'
USE_FANN_CASCADE = false

FANN_MAX_TARGET_WORD_PRE_POST = 20

class MyFann < RubyFann::Shortcut
#  class MyFann < RubyFann::Standard
  def training_callback(args)
    puts ("FANN ARGS: #{args.inspect}")
#    RAILS_DEFAULT_LOGGER.info("FANN ARGS: #{args.inspect}")
    return 0
  end
end

class FannAll

  def train(strategy)
    unless strategy.compressed_data_1 and strategy.compressed_data_2
      fann_paragraphs = []
      labels = []
    else
      fann_paragraphs = Marshal.load(Zlib::Inflate.inflate(strategy.compressed_data_1))
      labels = Marshal.load(Zlib::Inflate.inflate(strategy.compressed_data_2))
    end

    test_labels = []
    test_fann_paragraphs = []

    n =  ClassifiedParagraph.count_paragraphs_to_train_for_classification_strategy(strategy.id)
    number_to_classify = (n/8)*7.0
    number_to_validate = (n/8)*1.0
    
    puts number_to_validate
    pc = 0
    
    if n>500
      puts "Train FANN #{number_to_classify} entries"
      paragraphs = ClassifiedParagraph.get_paragraphs_to_train_for_classification_strategy(strategy.id, [number_to_classify.to_i,1].max)
      paragraphs.each do |paragraph|
#        puts "#{pc+=1}/#{number_to_classify} - #{paragraph.stemmed_processed_text_a.inspect}"
        case paragraph.objective_subjective_score
          when -2.0..-0.1
            case paragraph.sentiment_score
              when -2.0..-0.1 then
                fann_paragraphs << paragraph.stemmed_processed_texts(SVM_MAX_TARGET_WORD_PRE_POST)[0]
                labels << to_svm_label(:objective_negative)
              when 0.0 then
                fann_paragraphs << paragraph.stemmed_processed_texts(SVM_MAX_TARGET_WORD_PRE_POST)[0]
                labels << to_svm_label(:objective_neutral)
              when 0.1..2.0 then
                fann_paragraphs << paragraph.stemmed_processed_texts(SVM_MAX_TARGET_WORD_PRE_POST)[0]
                labels << to_svm_label(:objective_positive)
            end
          when 0.1..2.0
            case paragraph.sentiment_score
              when -2.0..-0.1 then
                fann_paragraphs << paragraph.stemmed_processed_texts(SVM_MAX_TARGET_WORD_PRE_POST)[0]
                labels << to_svm_label(:subjective_negative)
              when 0.0 then
                fann_paragraphs << paragraph.stemmed_processed_texts(SVM_MAX_TARGET_WORD_PRE_POST)[0]
                labels << to_svm_label(:subjective_neutral)
              when 0.1..2.0 then
                fann_paragraphs << paragraph.stemmed_processed_texts(SVM_MAX_TARGET_WORD_PRE_POST)[0]
                labels << to_svm_label(:subjective_positive)
            end
        end
        strategy.classified_paragraphs << paragraph
      end
      strategy.compressed_data_1 = Zlib::Deflate.deflate(Marshal.dump(fann_paragraphs))
      strategy.compressed_data_2 = Zlib::Deflate.deflate(Marshal.dump(labels))
  
      #strategy.save
      #puts strategy.inspect
    else
      puts "Less then 500 for FANN"
      number_to_validate =  ClassifiedParagraph.count_paragraphs_to_train_for_classification_strategy(strategy.id)
    end
    paragraphs = ClassifiedParagraph.get_paragraphs_to_train_for_classification_strategy(strategy.id, [number_to_validate.to_i,1].max)
    paragraphs.each do |paragraph|
#      puts "#{pc+=1}/#{number_to_classify} - #{paragraph.stemmed_processed_texts(SVM_MAX_TARGET_WORD_PRE_POST)[0].inspect}"
      case paragraph.objective_subjective_score
        when -2.0..-0.1
          case paragraph.sentiment_score
            when -2.0..-0.1 then
              test_fann_paragraphs << paragraph.stemmed_processed_texts(SVM_MAX_TARGET_WORD_PRE_POST)[0]
              test_labels << to_svm_label(:objective_negative)
            when 0.0 then
              test_fann_paragraphs << paragraph.stemmed_processed_texts(SVM_MAX_TARGET_WORD_PRE_POST)[0]
              test_labels << to_svm_label(:objective_neutral)
            when 0.1..2.0 then
              test_fann_paragraphs << paragraph.stemmed_processed_texts(SVM_MAX_TARGET_WORD_PRE_POST)[0]
              test_labels << to_svm_label(:objective_positive)
          end
        when 0.1..2.0
          case paragraph.sentiment_score
            when -2.0..-0.1 then
              test_fann_paragraphs << paragraph.stemmed_processed_texts(SVM_MAX_TARGET_WORD_PRE_POST)[0]
              test_labels << to_svm_label(:subjective_negative)
            when 0.0 then
              test_fann_paragraphs << paragraph.stemmed_processed_texts(SVM_MAX_TARGET_WORD_PRE_POST)[0]
              test_labels << to_svm_label(:subjective_neutral)
            when 0.1..2.0 then
              test_fann_paragraphs << paragraph.stemmed_processed_texts(SVM_MAX_TARGET_WORD_PRE_POST)[0]
              test_labels << to_svm_label(:subjective_positive)
          end
      end
    end

    # Build a global dictionary of all possible words
    dictionary = (fann_paragraphs+test_fann_paragraphs).flatten.uniq
    puts "Global dictionary: \\n #{dictionary.inspect}\\n\\n"
     
    # Build binary feature vectors for each document 
    #  - If a word is present in document, it is marked as '1', otherwise '0'
    #  - Each word has a unique ID as defined by 'dictionary' 
    feature_vectors = fann_paragraphs.map { |doc| dictionary.map{|x| doc.include?(x) ? 1 : 0} }
    test_vectors = test_fann_paragraphs.map { |doc| dictionary.map{|x| doc.include?(x) ? 1 : 0} }

    train = RubyFann::TrainData.new(:inputs=>feature_vectors, :desired_outputs=>labels_to_fann_format(labels))
    train.shuffle unless USE_FANN_CASCADE
    fann = nil
    if USE_FANN_CASCADE
      fann = RubyFann::Shortcut.new(:num_inputs=>dictionary.length, :num_outputs=>6)
    else
      fann = MyFann.new(:num_inputs=>dictionary.length, :hidden_neurons=>100000, :num_outputs=>6)
      fann.set_training_algorithm(:incremental)
    end

    if USE_FANN_CASCADE
      fann.cascadetrain_on_data(train, 300000, 100000, 0.005)
    else
      fann.train_on_data(train, 300000, 100000, 0.003)
    end
        
     # Test kernel performance on the training set
    total = errors = 0
    labels.each_index { |i|
      pred = fann.run(feature_vectors[i])
      puts "Prediction: #{pred.inspect}, True label: #{label_to_fann_format(labels[i]).inspect}"
      errors += 1 unless fuzzy_array_compare(label_to_fann_format(labels[i]),pred,0.5)
      total += 1
    }
    correct = total-errors
    correct_p = (correct.to_f/total.to_f)*100.0
    puts "Made #{errors} errors out of #{total} (#{correct_p}%) on the training set"
     
    # Test kernel performance on the test set
    total = errors = 0
    test_labels.each_index { |i|
      pred = fann.run(test_vectors[i])
      puts "\\t#{fuzzy_array_compare(label_to_fann_format(test_labels[i]),pred,0.5) ? '+' : '-'}Prediction: #{pred.inspect}, True label: #{label_to_fann_format(test_labels[i]).inspect}"
      errors += 1 unless fuzzy_array_compare(label_to_fann_format(test_labels[i]),pred,0.5)
      total += 1
    }
    correct = total-errors
    correct_p = (correct.to_f/total.to_f)*100.0
    puts "Made #{errors} errors out of #{total} (#{correct_p}%) on the test set"
  end
  
  def fuzzy_array_compare(a1,a2,deviation)
    match = true
    a1.each_index { |i|
      match = false if (a1[i]-a2[i]).abs>deviation
    }
    match
  end
  
  def label_to_fann_format(label)
    case label
      when 1 then
        [1.0,0.0,0.0,0.0,0.0,0.0]
      when 2 then
        [0.0,1.0,0.0,0.0,0.0,0.0]
      when 3 then
        [0.0,0.0,1.0,0.0,0.0,0.0]
      when 4 then
        [0.0,0.0,0.0,1.0,0.0,0.0]
      when 5 then
        [0.0,0.0,0.0,0.0,1.0,0.0]
      when 6 then
        [0.0,0.0,0.0,0.0,0.0,1.0]
    end    
  end
  
  def labels_to_fann_format(labels)
    fann_labels = []
    labels.each do |label|
      fann_labels << label_to_fann_format(label)
    end
    fann_labels
  end
end
