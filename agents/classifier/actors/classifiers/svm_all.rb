require 'SVM'
include SVM

#/home/robert/work/Downloads/
#libsvm/                     libsvm-ruby_2.8.4-1.diff
#libsvm-2.84/                libsvm-ruby_2.8.4.orig.tar
#libsvm_2.84.0.orig.tar      linuxx86/
#libsvm-ruby-2.8.4/          

SVM_MAX_TARGET_WORD_PRE_POST = 20

class SvmAll

  def train(strategy)
    unless strategy.compressed_data_1 and strategy.compressed_data_2
      svm_paragraphs = []
      labels = []
    else
      svm_paragraphs = Marshal.load(Zlib::Inflate.inflate(strategy.compressed_data_1))
      labels = Marshal.load(Zlib::Inflate.inflate(strategy.compressed_data_2))
    end

    test_labels = []
    test_svm_paragraphs = []

    n =  ClassifiedParagraph.count_paragraphs_to_train_for_classification_strategy(strategy.id)
    number_to_classify = (n/8)*7.0
    number_to_validate = (n/8)*1.0
    
    puts number_to_validate
    pc = 0
    
    if n>500
      puts "Train SVM #{number_to_classify} entries"
      paragraphs = ClassifiedParagraph.get_paragraphs_to_train_for_classification_strategy(strategy.id, [number_to_classify.to_i,1].max)
      paragraphs.each do |paragraph|
        puts "#{pc+=1}/#{number_to_classify} - #{paragraph.stemmed_processed_texts(SVM_MAX_TARGET_WORD_PRE_POST)[0].inspect}"
        case paragraph.objective_subjective_score
          when -2.0..-0.1
            case paragraph.sentiment_score
              when -2.0..-0.1 then
                svm_paragraphs << paragraph.stemmed_processed_texts(FANN_MAX_TARGET_WORD_PRE_POST)[0]
                labels << to_svm_label(:objective_negative)
              when 0.0 then
                svm_paragraphs << paragraph.stemmed_processed_texts(FANN_MAX_TARGET_WORD_PRE_POST)[0]
                labels << to_svm_label(:objective_neutral)
              when 0.1..2.0 then
                svm_paragraphs << paragraph.stemmed_processed_texts(FANN_MAX_TARGET_WORD_PRE_POST)[0]
                labels << to_svm_label(:objective_positive)
            end
          when 0.1..2.0
            case paragraph.sentiment_score
              when -2.0..-0.1 then
                svm_paragraphs << paragraph.stemmed_processed_texts(FANN_MAX_TARGET_WORD_PRE_POST)[0]
                labels << to_svm_label(:subjective_negative)
              when 0.0 then
                svm_paragraphs << paragraph.stemmed_processed_texts(FANN_MAX_TARGET_WORD_PRE_POST)[0]
                labels << to_svm_label(:subjective_neutral)
              when 0.1..2.0 then
                svm_paragraphs << paragraph.stemmed_processed_texts(FANN_MAX_TARGET_WORD_PRE_POST)[0]
                labels << to_svm_label(:subjective_positive)
            end
        end
        strategy.classified_paragraphs << paragraph
      end
      strategy.compressed_data_1 = Zlib::Deflate.deflate(Marshal.dump(svm_paragraphs))
      strategy.compressed_data_2 = Zlib::Deflate.deflate(Marshal.dump(labels))
  
      #strategy.save
      #puts strategy.inspect
    else
      puts "Less then 500 for SVM"
      number_to_validate =  ClassifiedParagraph.count_paragraphs_to_train_for_classification_strategy(strategy.id)
    end
    paragraphs = ClassifiedParagraph.get_paragraphs_to_train_for_classification_strategy(strategy.id, [number_to_validate.to_i,1].max)
    paragraphs.each do |paragraph|
#      puts "#{pc+=1}/#{number_to_classify} - #{paragraph.stemmed_processed_text_a.inspect}"
      case paragraph.objective_subjective_score
        when -2.0..-0.1
          case paragraph.sentiment_score
            when -2.0..-0.1 then
              test_svm_paragraphs << paragraph.stemmed_processed_texts(FANN_MAX_TARGET_WORD_PRE_POST)[0]
              test_labels << to_svm_label(:objective_negative)
            when 0.0 then
              test_svm_paragraphs << paragraph.stemmed_processed_texts(FANN_MAX_TARGET_WORD_PRE_POST)[0]
              test_labels << to_svm_label(:objective_neutral)
            when 0.1..2.0 then
              test_svm_paragraphs << paragraph.stemmed_processed_texts(FANN_MAX_TARGET_WORD_PRE_POST)[0]
              test_labels << to_svm_label(:objective_positive)
          end
        when 0.1..2.0
          case paragraph.sentiment_score
            when -2.0..-0.1 then
              test_svm_paragraphs << paragraph.stemmed_processed_texts(FANN_MAX_TARGET_WORD_PRE_POST)[0]
              test_labels << to_svm_label(:subjective_negative)
            when 0.0 then
              test_svm_paragraphs << paragraph.stemmed_processed_texts(FANN_MAX_TARGET_WORD_PRE_POST)[0]
              test_labels << to_svm_label(:subjective_neutral)
            when 0.1..2.0 then
              test_svm_paragraphs << paragraph.stemmed_processed_texts(FANN_MAX_TARGET_WORD_PRE_POST)[0]
              test_labels << to_svm_label(:subjective_positive)
          end
      end
    end

    # Build a global dictionary of all possible words
    dictionary = (svm_paragraphs+test_svm_paragraphs).flatten.uniq
    puts "Global dictionary: \\n #{dictionary.inspect}\\n\\n"
     
    # Build binary feature vectors for each document 
    #  - If a word is present in document, it is marked as '1', otherwise '0'
    #  - Each word has a unique ID as defined by 'dictionary' 
    feature_vectors = svm_paragraphs.map { |doc| dictionary.map{|x| doc.include?(x) ? 1 : 0} }
    test_vectors = test_svm_paragraphs.map { |doc| dictionary.map{|x| doc.include?(x) ? 1 : 0} }
     
#    puts "First training vector: #{feature_vectors.first.inspect}\\n"
#    puts "First test vector: #{test_vectors.first.inspect}\\n"
 
    # Define kernel parameters -- we'll stick with the defaults
    pa = Parameter.new
    pa.C = 100
    pa.svm_type = NU_SVC
    pa.degree = 1
    pa.coef0 = 0
    pa.eps= 0.001

    sp = Problem.new

    # Add svm_paragraphs to the training set
    labels.each_index { |i|
#      puts "labels[#{i}]:#{labels[i]} - feature_vectors[#{i}]:#{feature_vectors[i]}"
      sp.addExample(labels[i], feature_vectors[i])
    }

    # We're not sure which Kernel will perform best, so let's give each a try
    kernels = [ LINEAR, POLY, RBF, SIGMOID ]
    kernel_names = [ 'Linear', 'Polynomial', 'Radial basis function', 'Sigmoid' ]
#    kernels = [ LINEAR, POLY, RBF, SIGMOID ]
#    kernel_names = [ 'Linear', 'Polynomial', 'Radial basis function', 'Sigmoid' ]
     
    kernels.each_index { |j|
      # Iterate and over each kernel type
      pa.kernel_type = kernels[j]
      m = Model.new(sp, pa)
      errors = 0
      total = 0
     
      # Test kernel performance on the training set
      labels.each_index { |i|
        pred, probs = m.predict_probability(feature_vectors[i])
#        puts "Prediction: #{pred}, True label: #{labels[i]}, Kernel: #{kernel_names[j]}"
        errors += 1 if labels[i] != pred
        total += 1
      }
      correct = total-errors
      correct_p = (correct.to_f/total.to_f)*100.0
      puts "Kernel #{kernel_names[j]} made #{errors} errors out of #{total} (#{correct_p}%) on the training set"
     
      # Test kernel performance on the test set
      errors = 0
      total = 0
      test_labels.each_index { |i|
#        puts "ABOUT TO: #{test_vectors[i]}"
        pred, probs = m.predict_probability(test_vectors[i])
#        puts "\\t Prediction: #{pred}, True label: #{test_labels[i]}"
        errors += 1 if test_labels[i] != pred
        total += 1
      }
     
      correct = total-errors
      correct_p = (correct.to_f/total.to_f)*100.0
      puts "Kernel #{kernel_names[j]} made #{errors} errors out of #{total} (#{correct_p}%) on the test set"
    }    
  end

  def from_svm_label(label_number)
    case label_number
      when 1 then :objective_negative
      when 2 then :objective_neutral
      when 3 then :objective_positive
      when 4 then :subjective_negative
      when 5 then :subjective_neutral
      when 6 then :subjective_positive
    end
  end  

  def to_svm_label(label_symbol)
    case label_symbol
      when :objective_negative then 1
      when :objective_neutral then 2
      when :objective_positive then 3
      when :subjective_negative then 4
      when :subjective_neutral then 5
      when :subjective_positive then 6
    end
  end

end
