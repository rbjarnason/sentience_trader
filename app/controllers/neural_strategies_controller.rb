class NeuralStrategiesController < ApplicationController
  layout "main"

  # GET /neural_strategies
  # GET /neural_strategies.xml
  def index
    unless params[:only_id]
      @neural_strategies = NeuralStrategy.find(:all, :limit=>250)
    else
      @neural_strategies = NeuralStrategy.find(:all, :limit=>250)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @neural_strategies }
    end
  end

  # GET /neural_strategies/1
  # GET /neural_strategies/1.xml
  def show
    @neural_strategy = NeuralStrategy.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @neural_strategy }
    end
  end

  # GET /neural_strategies/new
  # GET /neural_strategies/new.xml
  def new
    @neural_strategy = NeuralStrategy.new
    @quote_targets = QuoteTarget.find(:all)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @neural_strategy }
    end
  end

  # GET /neural_strategies/1/edit
  def edit
    @neural_strategy = NeuralStrategy.find(params[:id])
    @quote_targets = QuoteTarget.find(:all)
  end

  # POST /neural_strategies
  # POST /neural_strategies.xml
  def create
    @neural_strategy = NeuralStrategy.new(params[:neural_strategy])
    @quote_targets = QuoteTarget.find(:all)
    @neural_strategy.quote_target_id = params[:quote_target_id]
    @neural_strategy.last_neural_processing_time = 0
    @neural_strategy.last_prediction_processing_time = 0
    respond_to do |format|
      if @neural_strategy.save
        flash[:notice] = 'NeuralStrategy was successfully created.'
        format.html { redirect_to(@neural_strategy) }
        format.xml  { render :xml => @neural_strategy, :status => :created, :location => @neural_strategy }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @neural_strategy.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /neural_strategies/1
  # PUT /neural_strategies/1.xml
  def update
    @neural_strategy = NeuralStrategy.find(params[:id])
    @quote_targets = QuoteTarget.find(:all)
    @neural_strategy.quote_target_id = params[:quote_target_id]
    @neural_strategy.last_neural_processing_time = 0
    @neural_strategy.last_prediction_processing_time = 0
    respond_to do |format|
      if @neural_strategy.update_attributes(params[:neural_strategy])
        flash[:notice] = 'NeuralStrategy was successfully updated.'
        format.html { redirect_to(@neural_strategy) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @neural_strategy.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /neural_strategies/1
  # DELETE /neural_strategies/1.xml
  def destroy
    @neural_strategy = NeuralStrategy.find(params[:id])
    @neural_strategy.destroy

    respond_to do |format|
      format.html { redirect_to(neural_strategies_url) }
      format.xml  { head :ok }
    end
  end
end
