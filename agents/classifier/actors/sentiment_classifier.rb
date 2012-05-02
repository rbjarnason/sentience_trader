# you can execute this nanite from the cli.rb command line example app

# gem install ruby-graphviz

require File.dirname(__FILE__) + '/../../../config/boot'
require "#{RAILS_ROOT}/config/environment"

require File.dirname(__FILE__) + '/../../../lib/paragraph_tools'

require 'zlib'
require 'rubygems'
require 'stemmer'

Dir.glob(File.join(File.dirname(__FILE__), '/classifiers/*.rb')).each {|f| require f }

class SentimentClassifier #  < Nanite::Actor

#  expose :train_one_random_strategy

  def reset_strategy
    @strategy.classified_paragraphs.delete_all
    @strategy.compressed_data_1 = nil
    @strategy.compressed_data_2 = nil
    @strategy.compressed_data_3 = nil
  end

  def train_one_random_strategy(payload)
#    @strategy = ClassificationStrategy.find(:first, :order=>"RAND()", :lock=>true)
    @strategy = ClassificationStrategy.find(1, :lock=>true)
    reset_strategy
    train_strategy
  end
  
  private
  
  def train_strategy
    case @strategy.classification_type
      when "bayesian_1" then
        BayesianAll.new.train(@strategy)
      when "bayesian_obj_subj_1" then
        BayesianObjSubj.new.train(@strategy)
      when "bayesian_pos_neg_1" then
        BayesianPosNeg.new.train(@strategy)
      when "lsi_1" then
        LsiAll.new.train(@strategy)
      when "svm_1" then
        SvmAll.new.train(@strategy)
      when "fann_1" then
        FannAll.new.train(@strategy)
    end
  end
end

classifier = SentimentClassifier.new
classifier.train_one_random_strategy(nil)

#Nanite.register(Classifier.new)

