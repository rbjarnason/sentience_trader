# encoding: UTF-8

class Prediction < ActiveRecord::Base
  belongs_to :neural_strategy
end