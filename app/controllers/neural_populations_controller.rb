class NeuralPopulationsController < ApplicationController
  layout "main"

  # GET /neural_populations
  # GET /neural_populations.xml
  def index
    @neural_populations = NeuralPopulation.find(:all, :limit=>250)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @neural_populations }
    end
  end

  # GET /neural_populations/1
  # GET /neural_populations/1.xml
  def show
    @neural_population = NeuralPopulation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @neural_population }
    end
  end

  # GET /neural_populations/new
  # GET /neural_populations/new.xml
  def new
    @neural_population = NeuralPopulation.new
    @quote_targets = QuoteTarget.find(:all)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @neural_population }
    end
  end

  # GET /neural_populations/1/edit
  def edit
    @quote_targets = QuoteTarget.find(:all)
    @neural_population = NeuralPopulation.find(params[:id])
  end

  # POST /neural_populations
  # POST /neural_populations.xml
  def create
    @neural_population = NeuralPopulation.new(params[:neural_population])
    @quote_targets = QuoteTarget.find(:all)
    @neural_population.quote_target_id = params[:quote_target_id]
    respond_to do |format|
      if @neural_population.save
        @neural_population.initialize_population
        @neural_population.active = 1
        @neural_population.save
        flash[:notice] = 'NeuralPopulation was successfully created.'
        format.html { redirect_to(@neural_population) }
        format.xml  { render :xml => @neural_population, :status => :created, :location => @neural_population }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @neural_population.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /neural_populations/1
  # PUT /neural_populations/1.xml
  def update
    @neural_population = NeuralPopulation.find(params[:id])
    @quote_targets = QuoteTarget.find(:all)
    @neural_population.quote_target_id = params[:quote_target_id]
    respond_to do |format|
      if @neural_population.update_attributes(params[:neural_population])
        flash[:notice] = 'NeuralPopulation was successfully updated.'
        format.html { redirect_to(@neural_population) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @neural_population.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /neural_populations/1
  # DELETE /neural_populations/1.xml
  def destroy
    @neural_population = NeuralPopulation.find(params[:id])
    @neural_population.destroy

    respond_to do |format|
      format.html { redirect_to(neural_populations_url) }
      format.xml  { head :ok }
    end
  end
end
