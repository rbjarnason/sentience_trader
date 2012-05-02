class ClassificationStrategiesController < ApplicationController
  layout "main"

  # GET /classification_strategies
  # GET /classification_strategies.xml
  def index
    @classification_strategies = ClassificationStrategy.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @classification_strategies }
    end
  end

  # GET /classification_strategies/1
  # GET /classification_strategies/1.xml
  def show
    @classification_strategy = ClassificationStrategy.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @classification_strategy }
    end
  end

  # GET /classification_strategies/new
  # GET /classification_strategies/new.xml
  def new
    @classification_strategy = ClassificationStrategy.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @classification_strategy }
    end
  end

  # GET /classification_strategies/1/edit
  def edit
    @classification_strategy = ClassificationStrategy.find(params[:id])
  end

  # POST /classification_strategies
  # POST /classification_strategies.xml
  def create
    @classification_strategy = ClassificationStrategy.new(params[:classification_strategy])

    respond_to do |format|
      if @classification_strategy.save
        flash[:notice] = 'ClassificationStrategy was successfully created.'
        format.html { redirect_to(@classification_strategy) }
        format.xml  { render :xml => @classification_strategy, :status => :created, :location => @classification_strategy }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @classification_strategy.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /classification_strategies/1
  # PUT /classification_strategies/1.xml
  def update
    @classification_strategy = ClassificationStrategy.find(params[:id])

    respond_to do |format|
      if @classification_strategy.update_attributes(params[:classification_strategy])
        flash[:notice] = 'ClassificationStrategy was successfully updated.'
        format.html { redirect_to(@classification_strategy) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @classification_strategy.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /classification_strategies/1
  # DELETE /classification_strategies/1.xml
  def destroy
    @classification_strategy = ClassificationStrategy.find(params[:id])
    @classification_strategy.destroy

    respond_to do |format|
      format.html { redirect_to(classification_strategies_url) }
      format.xml  { head :ok }
    end
  end
end
