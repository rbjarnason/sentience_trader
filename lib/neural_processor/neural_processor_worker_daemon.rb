$LOAD_PATH << File.expand_path(File.dirname(__FILE__))
require 'rubygems'
require 'yaml'
require 'daemons'
require 'rubygems'
require 'ruby_fann/neural_network'
require 'ruby_fann/neurotica'
require 'zlib'

f = File.open( File.dirname(__FILE__) + '/config/worker.yml')
worker_config = YAML.load(f)

ENV['RAILS_ENV'] = worker_config['rails_env']

#FILESYSTEM_TO_TEST = "/var/content/neural_processor_"+ENV['RAILS_ENV']+"/"
FILESYSTEM_TO_TEST = "/"

MASTER_TEST_MAX_COUNTER = 50000
MIN_FREE_SPACE_GB = 1
SLEEP_WAITING_FOR_FREE_SPACE_TIME = 120
SLEEP_WAITING_FOR_LOAD_TO_GO_DOWN = 120
SLEEP_WAITING_FOR_DAEMONS_TO_END = 120
SLEEP_WAITING_BETWEEN_RUNS = 0
SQL_RESET_TIME_SEC = 120

EMAIL_REPORTING_INTERVALS = 7200
SELLERS_DETECTION_THRESHOLD = 0.0
MAX_NUMBER_OF_DEAMONS = 1

require 'rubygems'

require 'sys/filesystem'
include Sys

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'


require File.dirname(__FILE__) + '/../utils/logger.rb'
require File.dirname(__FILE__) + '/../utils/shell.rb'

#require 'active_record'
#require 'actionmailer'


require File.dirname(__FILE__) + '/../../config/boot'
require "#{RAILS_ROOT}/config/environment" 

require File.dirname(__FILE__) + '/../../app/models/admin_mailer.rb'
include ActionView::Helpers::SanitizeHelper
require 'yaml'

class Array
  def random(weights=nil)
    return random(map {|n| n.send(weights)}) if weights.is_a? Symbol
    weights ||= Array.new(length, 1.0)
    total = weights.inject(0.0) {|t,w| t+w}
    point = rand * total
   
    zip(weights).each do |n,w|
    return n if w >= point
      point -= w
    end
  end
end

RAILS_DEFAULT_LOGGER = Logger.new( File.dirname(__FILE__) +"/neural_processor_worker_rails_"+ENV['RAILS_ENV']+".log")

  class MyFann < RubyFann::Shortcut
#  class MyFann < RubyFann::Standard
  def training_callback(args)
    RAILS_DEFAULT_LOGGER.info("FANN ARGS: #{args.inspect}")
    return 0
  end
end

class NeuralProcessorWorker
  def initialize(config)
    @logger = RAILS_DEFAULT_LOGGER
#    @logger = Logger.new( File.dirname(__FILE__) +"/neural_processor_worker_"+ENV['RAILS_ENV']+".log")
    @shell = Shell.new(self)
    @worker_config = config
    @counter = 0
    @last_report_time = 0
  end

  def log_time
    t = Time.now
    "%02d/%02d %02d:%02d:%02d.%06d" % [t.day, t.month, t.hour, t.min, t.sec, t.usec]
  end

  def info(text)
    @logger.info("cs_info %s: %s" % [log_time, text])
  end

  def warn(text)
    @logger.warn("cs_warn %s: %s" % [log_time, text])
  end

  def error(text)
    @logger.error("cs_error %s: %s" % [log_time, text])
    #TODO: SEND ADMIN EMAIL
  end

  def debug(text)
    @logger.debug("cs_debug %s: %s" % [log_time, text])
  end
  
  def process_neural_target
    debug("process_neural_target")
    @neural_strategy.setup(@logger)
#    debug(@neural_strategy.inspect)
    if @neural_strategy.get_inputs and  @neural_strategy.get_inputs.length > 0
      begin
        outputs = @neural_strategy.get_desired_outputs
        inputs = @neural_strategy.get_inputs
#        debug("INPUT:"+input.inspect)
        rand_file_name = File.dirname(__FILE__) + "/nets/temp.net_#{rand(213544)}"
        rand_file_name_out = File.dirname(__FILE__) + "/nets/temp.net_#{rand(213544)}"
        rand_file_name_training_data = File.dirname(__FILE__) + "/nets/training.data_#{rand(213544)}.data"
        File.delete(rand_file_name) if File.exist?(rand_file_name)
        File.delete(rand_file_name_out) if File.exist?(rand_file_name_out)
        fann=nil
        train=nil
        train = RubyFann::TrainData.new(:inputs=>inputs, :desired_outputs=>outputs)
        train.shuffle unless @neural_strategy.use_cascade?
#       debug("inputs: (#{@neural_strategy.get_inputs.length}) #{@neural_strategy.get_inputs.inspect}")
#       debug("outputs: (#{@neural_strategy.get_desired_outputs.length}) #{@neural_strategy.get_desired_outputs.inspect}")
#        if @neural_strategy.network and @neural_strategy.network.length>20
##            debug("Loading net from file")
#          f = File.new(rand_file_name, "wb")
#          f.write(@neural_strategy.network.to_s)
#          f.close()
#          f=nil
#          fann = MyFann.new(:filename=>rand_file_name)
#        else
#         debug("Creating a new file")
#         debug("Creating a new file - num inputs #{@neural_strategy.get_num_inputs} - hidden: #{@neural_strategy.hidden_neurons.to_s} - max_epochs: #{@neural_strategy.max_epochs} - num_outputs: #{@neural_strategy.get_num_outputs}")
        debug("Creating a new file - num inputs #{@neural_strategy.get_num_inputs} - num hidden #{@neural_strategy.hidden_neurons ? @neural_strategy.hidden_neurons.length : -1} - desired_error #{@neural_strategy.desired_error} - max_epochs: #{@neural_strategy.max_epochs} - num_outputs: #{@neural_strategy.get_num_outputs}")
        fann = nil
        if @neural_strategy.use_cascade?
          info("CASCADE TRAINING")
          fann = RubyFann::Shortcut.new(:num_inputs=>@neural_strategy.get_num_inputs, :num_outputs=>@neural_strategy.get_num_outputs)
        else
          info("NORMAL TRAINING")
          fann = MyFann.new(:num_inputs=>@neural_strategy.get_num_inputs, :hidden_neurons=>@neural_strategy.hidden_neurons, :num_outputs=>@neural_strategy.get_num_outputs)
          fann.set_training_algorithm(:incremental)
#          fann.set_activation_function_hidden(:sigmoid)
#          fann.set_activation_function_output(:sigmoid)
        end
        if @neural_strategy.use_cascade?
          #fann.set_cascade_max_out_epochs(50000)
          #fann.set_cascade_max_cand_epochs(50000)
#          fann.set_cascade_activation_functions(:sigmoid)
#          fann.set_cascade_activation_function_output(:sigmoid)
          fann.cascadetrain_on_data(train, @neural_strategy.max_epochs, 10000, @neural_strategy.desired_error)
          #          fann.cascadetrain_on_data(train, @neural_strategy.max_epochs, 100, @neural_strategy.desired_error)
#          fann.cascadetrain_on_data(train, @neural_strategy.max_epochs, 100, @neural_strategy.desired_error)
        else
          fann.train_on_data(train, @neural_strategy.max_epochs, 100000, @neural_strategy.desired_error)
        end
        debug("Saving net")
        fann.save(rand_file_name_out)
        f = File.open(rand_file_name_out, "rb")
        @neural_strategy.compressed_network = Zlib::Deflate.deflate(f.read, Zlib::BEST_COMPRESSION)
        f.close()
        f = nil
#        f = File.open(rand_file_name_training_data, "w")
#        f.write("#{@neural_strategy.get_inputs.length} #{@neural_strategy.get_num_inputs} #{@neural_strategy.get_num_outputs}\n")
#        count = 0
#        @neural_strategy.get_inputs.length.times {
#          inputs_str = ""
#          inputs[count].each do |input_str|
#            inputs_str += "#{input_str} "
#          end
#          outputs_str = ""
#          outputs[count].each do |output_str|
#            outputs_str += "#{output_str} "
#          end
#          f.write("#{inputs_str}\n")
#          f.write("#{outputs_str}\n")
#          count += 1
#        }
#        f.close()
#        f = nil
#        debug("new inputs: #{inputs.inspect} output: #{outputs.inspect}")
        debug("Prediction start - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  ")
        @neural_strategy.prediction_list.each do |quote_value|
          @neural_strategy.max_epochs = 100 if @neural_strategy.max_epochs<10
#          fann = MyFann.new(:filename=>rand_file_name_out)
#          debug("Fann #{fann} Testing values: #{quote_value.get_neural_input(@neural_strategy.selected_inputs,@neural_strategy.inputs_scaling).inspect}")
          prediction_value = fann.run(quote_value.get_neural_input(@neural_strategy.selected_inputs,@neural_strategy.inputs_scaling))
          if prediction_value
            debug("Prediction VALUE #{prediction_value.inspect} for quote value #{quote_value.get_desired_output} for #{@neural_strategy.id}")
            prediction = Prediction.new
            prediction.double_value = prediction_value[0]
            prediction.data_time = quote_value.created_at
            prediction.last_trade = quote_value.last_trade
            prediction.neural_strategy_id = @neural_strategy.id
            prediction.save
          end
        end
        rand_graph_name = File.dirname(__FILE__) + "/nets/temp.net_graph_#{rand(256)}.png"
        graph = RubyFann::Neurotica.new
        graph.graph(fann,rand_graph_name) 
        File.delete(rand_file_name) if File.exist?(rand_file_name)
        File.delete(rand_file_name_out) if File.exist?(rand_file_name_out)
      rescue => ex
        error("Error processing NN #{ex} #{ex.backtrace}")
        @neural_strategy.error_flag = 1
      end
    else
      debug("No data to process")
      @neural_strategy.error_flag = 1
    end
    fann=nil
    @neural_strategy.in_process = 0
    @neural_strategy.complete = 1
    @neural_strategy.last_processing_stop_time = Time.now
    @neural_strategy.save
  end

  def poll_for_neural_work
    debug("poll_for_neural_work")
#    NeuralStrategy.transaction do
      @neural_strategy = NeuralStrategy.find(:first, :conditions => "active = 1 AND in_process = 0 AND complete = 0 AND error_flag = 0", :order => 'rand()', :lock=>true)
      if @neural_strategy and @neural_strategy.complete = 0 and @neural_strategy.in_process = 0 and @neural_strategy.error_flag = 0
        debug("processing neural strategy: #{@neural_strategy.id}")
        @neural_strategy.in_process = 1
        @neural_strategy.last_work_unit_time = 0
        @neural_strategy.last_neural_processing_time = Time.now
        @neural_strategy.last_processing_start_time = Time.now
        @neural_strategy.save
        @neural_strategy.reload(:lock => true)
        process_neural_target
      end
#    end
  end

  def process_population_target
    @population.evolve
#    @population.in_process = 0
    @population.last_processing_stop_time = Time.now
    @population.in_process = 1 
    @population.save
  end

  def poll_for_evolution_work
    debug("poll_for_evolution_work")
    NeuralPopulation.transaction do
      @population = NeuralPopulation.find(:first, :conditions => "active = 1 AND complete = 0 AND in_process = 1", :order => 'rand()', :lock=>true)
      if @population and @population.is_generation_testing_complete?
  #        @population.deactivate_all_neural_strategies_in_process
  #      info("#{@population.inspect}")
  #      info("LPT: #{@population.last_processing_start_time}")
        @population.last_processing_start_time = Time.now
        @population.in_process = 0
        @population.save
        @population.reload(:lock => true)
        process_population_target
     end
    end
  end
    
  def load_avg
    results = ""
    IO.popen("cat /proc/loadavg") do |pipe|
      pipe.each("\r") do |line|
        results = line
        #$defout.flush
      end
    end
    results.split[0..2].map{|e| e.to_f}
  end

  def check_load_and_wait
    loop do
      break if load_avg[0] < @worker_config["max_load_average"]
      info("Load Average #{load_avg[0]}, #{load_avg[1]}, #{load_avg[2]}")      
      info("Load average too high pausing for #{SLEEP_WAITING_FOR_LOAD_TO_GO_DOWN}")
      sleep(SLEEP_WAITING_FOR_LOAD_TO_GO_DOWN)
    end
  end

  def email_progress_report(freeGB)
    info("emailing report")
    begin
      report = AdminMailer.create_report("Crawler Unit #{@worker_config['neural_processor_server_id']} Reporting",
       "Free neural_processor space in GB #{freeGB} - Run count: #{@counter}\n\nLoad Average #{load_avg[0]}, #{load_avg[1]}, #{load_avg[2]}")
      report.set_content_type("text/html")
      AdminMailer.deliver(report)
    rescue => ex
      error(ex)
      error(ex.backtrace)
    end
    #TODO: Add time of email
  end

  def run
    info("Starting loop")
    @daemon_count = 0
    @daemons = []
    loop do
      stat = Filesystem.stat(FILESYSTEM_TO_TEST)
      freeGB = (stat.block_size * stat.blocks_available) /1024 / 1024 / 1024
      if @last_report_time+EMAIL_REPORTING_INTERVALS<Time.now.to_i
        email_progress_report(freeGB) unless ENV['RAILS_ENV']=="development"
        @last_report_time = Time.now.to_i
      end
      info("Free neural space in GB #{freeGB} - Run count: #{@counter}")
      info("Load Average #{load_avg[0]}, #{load_avg[1]}, #{load_avg[2]}")      
      if load_avg[0] < @worker_config["max_load_average"]
        if freeGB > MIN_FREE_SPACE_GB
          if 1==2 and ENV['RAILS_ENV'] == 'development' && @counter > MASTER_TEST_MAX_COUNTER
            warn("Reached maximum number of test runs - sleeping for an hour")
            sleep(3600)
          else
            @counter = @counter + 1
            begin
              poll_for_evolution_work
              poll_for_neural_work
            rescue => ex
              error("Problem with neural_processor worker #{ex} #{ex.backtrace}")
            end
          end
          if SLEEP_WAITING_BETWEEN_RUNS > 0
            info("Sleeping for #{SLEEP_WAITING_BETWEEN_RUNS} sec")
            sleep(SLEEP_WAITING_BETWEEN_RUNS)
          end
        else
          info("No more space on disk for cache - sleeping for #{SLEEP_WAITING_FOR_FREE_SPACE_TIME} sec")
          sleep(SLEEP_WAITING_FOR_FREE_SPACE_TIME)
        end
      else
        info("Load average too high at: #{load_avg[0]} - sleeping for #{SLEEP_WAITING_FOR_LOAD_TO_GO_DOWN} sec")
        sleep(SLEEP_WAITING_FOR_LOAD_TO_GO_DOWN)
      end
    end
    puts "THE END"
  end
end

config = YAML::load(File.open(File.dirname(__FILE__) + "/../../config/database.yml"))
ENV['RAILS_ENV'] = worker_config['rails_env']

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(config[ENV['RAILS_ENV']])
ActionMailer::Base.template_root = "views/" 
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
	:address => "mail.streamburst.co.uk",
	:port => 25,
	:domain => "streamburst.tv",
	 :authentication => :login,
	 :user_name => "robert@streamburst.co.uk",
	 :password => "runner44"
}

neural_processor_worker = NeuralProcessorWorker.new(worker_config)
neural_processor_worker.run

