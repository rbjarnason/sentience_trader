# encoding: UTF-8

TRADING_HOURS_START = 14
TRADING_HOURS_STOP = 19

#FITNESS_SORTING_METHOD="last_5"
#FITNESS_SORTING_METHOD="last_10"
#FITNESS_SORTING_METHOD="cumalative_all"
FITNESS_SORTING_METHOD="by_investment_strategy"

class NeuralStrategy < ActiveRecord::Base
  belongs_to :quote_target
  has_and_belongs_to_many :neural_populations
  has_many :predictions
  attr_reader :prediction_list, :selected_inputs, :inputs_scaling, :hidden_neurons, :signal_threshold_settings
  after_initialize :setup_time_span, :demarshall_input_arrays, :demarshall_hidden_neurons_setup
  before_save :marshall_input_arrays, :marshall_hidden_neurons_setup

  def demarshall
    setup_time_span
    demarshall_input_arrays
    demarshall_hidden_neurons_setup
  end

  def setup(logger)
    setup_time_span
    demarshall_input_arrays
    demarshall_hidden_neurons_setup
    @logger = logger
    timespan = nil
    RAILS_DEFAULT_LOGGER.info("SETUP #{self.id}")
    if self.network_type == "only_delayed_stock_data_1"
      @num_outputs = 1      
      @inputs = []
      @desired_outputs = []
      @prediction_list = []
      quote_value = self.quote_target.quote_values.find(:first, :order=>"created_at ASC")
      unless self.last_work_unit_time
        self.last_work_unit_time = quote_value.created_at if quote_value
      end 
      @first_time = quote_value.created_at.to_i
#      @mid_time =  Time.at(@first_time+((Time.now.to_i-@first_time)/2))
      @mid_time = Time.now-3.weeks
      found_at_least_one = false
      if self.last_work_unit_time
        @logger.info("Processing temporal time: #{self.last_work_unit_time}")
        begin          
#          input = self.quote_target.quote_values.get_one_by_time(self.last_work_unit_time)
          timespan = @timespan
          if am_i_inside_trading_hours? or not self.only_trading_hours or (@timespan>8.hours)
            input = get_cached_quote_value(self.last_work_unit_time) 
            timespan = @timespan+2.days if @timespan==1.day and self.last_work_unit_time.wday==5 # Jump to Monday
             output = get_cached_quote_value(self.last_work_unit_time+timespan)
  #          output = self.quote_target.quote_values.get_one_by_time(self.last_work_unit_time+timespan)
  #          @logger.debug("selected_inputs: #{self.selected_inputs.inspect}")
  #          @logger.debug("inputs_scaling #{self.inputs_scaling.inspect}")
            neural_inputs = input.get_neural_input(self.selected_inputs,self.inputs_scaling) if input
  #          @logger.debug("neural_inputs: #{neural_inputs.inspect}")
            if input and output and neural_inputs.length>0
              found_at_least_one = true
#              @logger.debug("Input: #{input.id} from #{input.created_at} length #{neural_inputs.length}")
#              @logger.debug("Output: #{input}")
              @num_inputs = neural_inputs.length unless @num_inputs
              if self.last_work_unit_time<@mid_time
                @inputs << neural_inputs
                desired_output_a = []
                desired_output_a << output.get_desired_output    
                @desired_outputs << desired_output_a
              else
                @prediction_list << output
              end
            else
  #            @logger.debug("No Data")
            end
          end
          self.last_work_unit_time = self.last_work_unit_time + timespan
#          @logger.debug("Next temporal time: #{self.last_work_unit_time}")
        end while (self.last_work_unit_time<Time.now-1.hour)
      else
        @logger.error("No last work unit time")
      end
      self.last_work_unit_time = self.last_work_unit_time - timespan unless found_at_least_one
    end
  end

  def get_inputs
#    @logger.debug(@inputs.inspect)
    @inputs
  end

  def get_num_inputs
    @num_inputs    
  end
  
  def get_num_outputs
    @num_outputs
  end
  
  def get_desired_outputs
    @desired_outputs
  end
  
  def get_signal_threshold_settings
    @signal_threshold_settings
  end
  
  def fitness_test
    demarshall_input_arrays
    total_inputs = 0
    for si in self.selected_inputs
      total_inputs += 1 if si == 1
    end
    total_inputs.to_f
  end
  
  def get_fann_scaling
    if [1,6].include?(self.quote_target.id)
      1000.0
    elsif [10].include?(self.quote_target.id)
      10.0
    else
      100.0
    end
  end

  def fitness
    setup_time_span
    prediction_distances = []
#    RAILS_DEFAULT_LOGGER.info("Neural Strategy Id: #{self.id} Predictions #{self.predictions.inspect}")
    for prediction in self.predictions
      from_date=prediction.data_time+@timespan
#      RAILS_DEFAULT_LOGGER.info("From data #{from_date}")
      quote=get_cached_quote_value(from_date)
#      RAILS_DEFAULT_LOGGER.info("#{quote.inspect}") if quote
      if quote
        prediction_distances << (((quote.last_trade.to_f/(prediction.double_value*get_fann_scaling))-1)*100)        
      end
    end
    #RAILS_DEFAULT_LOGGER.info("FAverage: NeuralStrategy id: #{self.id} PREDICTION DISTANCES: #{prediction_distances.inspect} self: #{self.predictions} qta: #{self.quote_target_id} timespan: #{@timespan}")
    if prediction_distances.length>2
      average=0.0
      if FITNESS_SORTING_METHOD=="best_6_in_a_row"
        best = 10.0
        count = 0
        (prediction_distances.length-5).times do
          current = 0.0
          current += prediction_distances[count].abs
          current += prediction_distances[count+1].abs
          current += prediction_distances[count+2].abs
          current += prediction_distances[count+3].abs
          current += prediction_distances[count+4].abs
          current += prediction_distances[count+5].abs
          best = current if best>current
          count += 1
        end
        RAILS_DEFAULT_LOGGER.info("FAverage best_6_in_a_row: #{prediction_distances.inspect}")
        RAILS_DEFAULT_LOGGER.info("FAverage: best #{best} fitness: #{10-best}")
        10-best
      elsif FITNESS_SORTING_METHOD=="cumalative_all" or FITNESS_SORTING_METHOD=="by_investment_strategy"
        all = 0.0
        prediction_distances.each {|a| all+=a.abs}
        RAILS_DEFAULT_LOGGER.info("FAverage cumalative_all #{prediction_distances.inspect}")
        RAILS_DEFAULT_LOGGER.info("FAverage: best #{all} fitness: #{100-all}")
        investment_strategy = InvestmentStrategy.new
        fitness = investment_strategy.get_prediction_details(self)
        fitness_final = fitness.nan? ? 0.00001 : fitness
        RAILS_DEFAULT_LOGGER.info("Fitness finall: #{fitness_final}")
        fitness_final+((100-all)*5)
      elsif FITNESS_SORTING_METHOD=="average_best_5"
        prediction_distances.sort[0..4].each {|a| average+=a.abs}
        10-(average/5)
      elsif FITNESS_SORTING_METHOD=="average_last_5"
        prediction_distances[prediction_distances.length-5..prediction_distances.length-1].each {|a| average+=a.abs}        
        RAILS_DEFAULT_LOGGER.info("FAverage last 5: #{prediction_distances[prediction_distances.length-5..prediction_distances.length-1].inspect}")
        RAILS_DEFAULT_LOGGER.info("FAverage: #{average/5} fitness: #{10-(average/5)}")
        10-(average/5)
      elsif FITNESS_SORTING_METHOD=="average_last_10"
        prediction_distances[prediction_distances.length-10..prediction_distances.length-1].each {|a| average+=a.abs}        
        RAILS_DEFAULT_LOGGER.info("FAverage last 10: #{prediction_distances[prediction_distances.length-10..prediction_distances.length-1].inspect}")
        RAILS_DEFAULT_LOGGER.info("FAverage: #{average/10} fitness: #{10-(average/10)}")
        10-(average/10)
      elsif FITNESS_SORTING_METHOD=="average_all"
        prediction_distances.each {|a| average+=a.abs}        
        RAILS_DEFAULT_LOGGER.info("FAverage all: #{prediction_distances.inspect}")
        RAILS_DEFAULT_LOGGER.info("FAverage: #{average/prediction_distances.length} fitness: #{10-(average/prediction_distances.length)}")
        10-(average/prediction_distances.length)
      end
    else
      0.0
    end
  end

  def import_settings_from_population(neural_population,setting)
    number_of_hidden_neurons = nil
    hidden_neuron_scalings = nil
    self.quote_target_id = neural_population.quote_target_id
    self.network_type = neural_population.network_type
    self.time_span_type = neural_population.time_span_type
    setting.get_genotypes.each do |genotype|
      if genotype.instance_of?(InputSelection)
        @selected_inputs = genotype.genes
      elsif genotype.instance_of?(InputScaling)
        @inputs_scaling = genotype.genes
      elsif genotype.instance_of?(SignalThresholdSettings)
        @signal_threshold_settings = genotype.genes
      elsif genotype.instance_of?(NumberOfHiddenNeurons)
        number_of_hidden_neurons = [genotype.genes[0].to_i.abs,1].max
        RAILS_DEFAULT_LOGGER.info("RVB Number of hidden: #{number_of_hidden_neurons}")
      elsif genotype.instance_of?(HiddenNeuronsScaling)
        hidden_neuron_scalings = genotype.genes
      elsif genotype.instance_of?(MaxEpochs)
        self.max_epochs = genotype.genes[0].to_i.abs
      elsif genotype.instance_of?(DesiredError)
        self.desired_error = genotype.genes[0].to_f.abs
      end
    end
    if number_of_hidden_neurons
      @hidden_neurons = []
      for number in 0..number_of_hidden_neurons-1
        @hidden_neurons << [hidden_neuron_scalings[number].to_i,1].max
      end
    end
    RAILS_DEFAULT_LOGGER.info("Id: #{self.id} Max Epochs: #{self.max_epochs} Desired error: #{self.desired_error} Hidden Neurons: #{@hidden_neurons.inspect} Selected inputs: #{@selected_inputs.inspect} Input scaling: #{@inputs_scaling.inspect}")
  end

  def use_cascade?
    self.selected_inputs[55]==1
  end

  def sell_by_prediction?
    self.selected_inputs[56]==1
  end

  private

  def get_cached_quote_value(from_time)
    key = "#{self.quote_target.id}#{from_time.to_i}"
    cached = QUOTE_VALUES_CACHE[key]
    unless cached and cached[0]>=Time.now-QUOTE_VALUES_CACHE_TIMEOUT
      cached = [Time.now,self.quote_target.quote_values.find(:first, :conditions=>["created_at >= ?",from_time], :order=>"created_at ASC")]
      QUOTE_VALUES_CACHE[key] = cached
    end
    cached[1]
  end

  def marshall_input_arrays
    self.selected_inputs_data = Marshal.dump(self.selected_inputs) if self.selected_inputs
    self.inputs_scaling_data = Marshal.dump(self.inputs_scaling) if self.inputs_scaling
    self.signal_threshold_settings_data = Marshal.dump(self.signal_threshold_settings) if self.signal_threshold_settings
  end

  def demarshall_input_arrays
    @selected_inputs = Marshal.load(self.selected_inputs_data) if self.selected_inputs_data
    @inputs_scaling = Marshal.load(self.inputs_scaling_data) if self.inputs_scaling_data
    @signal_threshold_settings = Marshal.load(self.signal_threshold_settings_data) if self.signal_threshold_settings_data
  end
  
  def marshall_hidden_neurons_setup
    self.hidden_neurons_data = Marshal.dump(self.hidden_neurons) if self.hidden_neurons
  end

  def demarshall_hidden_neurons_setup
    if self.hidden_neurons_data
      hidden_neurons = Marshal.load(self.hidden_neurons_data) 
      @hidden_neurons = []
      hidden_neurons.each do |hn|
        if hn==0
          @hidden_neurons << 1
        else
          @hidden_neurons << hn
        end
      end
    end
  end
    
  def setup_time_span
    if self.time_span_type == "1_hour"
      @timespan=1.hour
    elsif self.time_span_type == "1_day"
      @timespan=1.day
    elsif self.time_span_type == "1_week"
      @timespan=1.week
    end
  end

  def am_i_inside_trading_hours?
    hour = self.last_work_unit_time.hour
    wday = self.last_work_unit_time.wday
    if hour>=TRADING_HOURS_START and hour<=TRADING_HOURS_STOP and not [6,0].include?(wday)
      return true
    else
      return false
    end
  end
end
