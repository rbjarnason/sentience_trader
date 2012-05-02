# encoding: UTF-8

class InputSelection < BitStringGenotype(60)
  use Elitism(TruncationSelection(0.3),1), UniformCrossover, ListMutator(:probability[ p=0.15],:flip)
end

class InputScaling <  FloatListGenotype(40)
  use Elitism(TruncationSelection(0.3),1), UniformCrossover, ListMutator(:probability[ p=0.10 ],:uniform[ max_size=10])
end

class NumberOfHiddenNeurons <  FloatListGenotype(1)
  use Elitism(TruncationSelection(0.5),1), NullCrossover, ListMutator(:probability[ p=0.10 ],:uniform[ max_size=25])
end

class HiddenNeuronsScaling <  FloatListGenotype(1200)
  use Elitism(TruncationSelection(0.3),1), UniformCrossover, ListMutator(:probability[ p=0.10 ],:uniform[ max_size=5])
end

class MaxEpochs <  FloatListGenotype(1)
  use Elitism(TruncationSelection(0.5),1), NullCrossover, ListMutator(:probability[ p=0.12 ],:uniform[ max_size=100000])
end

class DesiredError <  FloatListGenotype(1)
  use Elitism(TruncationSelection(0.5),1), NullCrossover, ListMutator(:probability[ p=0.25 ],:uniform[ max_size=0.0001])
end

class SignalThresholdSettings <  FloatListGenotype(2)
  use Elitism(TruncationSelection(0.3),1), NullCrossover, ListMutator(:probability[ p=0.15 ],:uniform[ max_size=0.001])
end

genotypes = []
genotypes << [InputSelection,nil]
genotypes << [InputScaling,(-1000.0..1000.0)]
genotypes << [NumberOfHiddenNeurons,(1..1024)]
genotypes << [HiddenNeuronsScaling,(1..20)]
genotypes << [MaxEpochs,10000..900000]
genotypes << [DesiredError,(0.0000001..0.000002)]
genotypes << [SignalThresholdSettings,(0.001..0.02)]

class NeuralNetSetting < ComboGenotype(genotypes)
  attr_reader :neural_strategy_id
  attr_writer :neural_strategy_id

  def fitness=(f)
    @ifitness=f
#    RAILS_DEFAULT_LOGGER.info("set fitness for #{self.object_id} to #{f}")
  end

  def fitness
#    RAILS_DEFAULT_LOGGER.info("get fitness for #{self.object_id} from #{@ifitness}")
    @ifitness
  end
  
#  use Elitism(TruncationSelection(0.3),1), ComboCrossover, ComboMutator()
  use Elitism(TruncationSelection(0.3),2), ComboCrossover, ComboMutator()
end

class NeuralPopulation < ActiveRecord::Base
  belongs_to :quote_target
  has_and_belongs_to_many :neural_strategies do
    def count_not_complete
      count :all, :conditions=>["complete = ?",0]
    end
  end

  attr_reader :population
  before_save :marshall_population
  after_initialize :demarshall_population
#    debug(@neural_strategy.inspect)

  def initialize_population
    @population = NetworkedPopulation.new(NeuralNetSetting,self.population_size)
    create_neural_strategies(@population)
  end

  def evolve
    demarshall_population unless @population
    RAILS_DEFAULT_LOGGER.info("evolve")
    unless @population.complete or self.current_generation>=self.max_generations
      import_population_fitness
      @population = @population.evolve_incremental_block(self.max_generations,RAILS_DEFAULT_LOGGER)
      create_neural_strategies(@population)
      self.current_generation = @population.generation
      RAILS_DEFAULT_LOGGER.info("Generation: #{self.current_generation}")
    else
      RAILS_DEFAULT_LOGGER.info("Reached max generations")
      self.complete=true
    end
    #remove_bottom_strategies
  end

  def is_generation_testing_complete?
#    complete = true
#    for ns in self.neural_strategies
#      if ns.complete==false
#        complete=false
#      end
#    end
    #self.neural_strategies.count(:conditions=>["complete = ?",0])
#    RAILS_DEFAULT_LOGGER.info("POPID: #{self.id} - LEN: #{self.neural_strategies.length} COUNT: #{self.neural_strategies.count(:all)} COMPLETE: #{complete}")
    strategies = self.neural_strategies.find(:all,:conditions=>"complete = 0 AND error_flag = 0")
    (strategies.length==0)
  end

  def deactivate_all_neural_strategies_in_process
    self.neural_strategies.each do |strategy|
      strategy.in_population_process = false
      strategy.save
    end
  end

  private

  def import_population_fitness
    RAILS_DEFAULT_LOGGER.info("import_population_fitness")
    for strategy in @population
      neural_strategy = NeuralStrategy.find(strategy.neural_strategy_id)
      strategy.fitness=neural_strategy.fitness
      self.best_fitness = -1000000.0 unless self.best_fitness
      if strategy.fitness > self.best_fitness
        self.best_fitness = strategy.fitness
        self.best_neural_strategy_id = neural_strategy.id
      end
    end
  end

  def marshall_population
#    RAILS_DEFAULT_LOGGER.info(@population.inspect) if @population
    self.population_data = Marshal.dump(@population) if @population
  end

  def demarshall_population
#    RAILS_DEFAULT_LOGGER.debug(self.population_data.inspect)
    @population = Marshal.load(self.population_data) if self.population_data
    
  end
  
  def remove_bottom_strategies(upto=2)
    if @population.length>upto
      for strategy in @population[@population.length-upto..@population.length-1]
        neural_strategy = NeuralStrategy.find(strategy.neural_strategy_id)
        neural_strategy.predictions.destroy_all
        neural_strategy.destroy
      end
    end
  end

  def create_neural_strategies(neural_net_settings)
    RAILS_DEFAULT_LOGGER.info("create_neural_strategies")
    for setting in neural_net_settings
      neural_strategy = NeuralStrategy.new
      neural_strategy.import_settings_from_population(self,setting)
      neural_strategy.active = true
      neural_strategy.in_population_process = true
      neural_strategy.save
      self.neural_strategies << neural_strategy
      setting.neural_strategy_id = neural_strategy.id
      RAILS_DEFAULT_LOGGER.info("create_neural_strategies id: #{neural_strategy.id}")
    end
  end  
end