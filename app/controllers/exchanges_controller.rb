class ExchangesController < ApplicationController
  layout "main"

  # GET /exchanges
  # GET /exchanges.xml
  def index
    @exchanges = Exchanges.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exchanges }
    end
  end

  # GET /exchanges/1
  # GET /exchanges/1.xml
  def show
    @exchanges = Exchanges.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @exchanges }
    end
  end

  # GET /exchanges/new
  # GET /exchanges/new.xml
  def new
    @exchanges = Exchanges.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @exchanges }
    end
  end

  # GET /exchanges/1/edit
  def edit
    @exchanges = Exchanges.find(params[:id])
  end

  # POST /exchanges
  # POST /exchanges.xml
  def create
    @exchanges = Exchanges.new(params[:exchanges])

    respond_to do |format|
      if @exchanges.save
        flash[:notice] = 'Exchanges was successfully created.'
        format.html { redirect_to(@exchanges) }
        format.xml  { render :xml => @exchanges, :status => :created, :location => @exchanges }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @exchanges.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /exchanges/1
  # PUT /exchanges/1.xml
  def update
    @exchanges = Exchanges.find(params[:id])

    respond_to do |format|
      if @exchanges.update_attributes(params[:exchanges])
        flash[:notice] = 'Exchanges was successfully updated.'
        format.html { redirect_to(@exchanges) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @exchanges.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /exchanges/1
  # DELETE /exchanges/1.xml
  def destroy
    @exchanges = Exchanges.find(params[:id])
    @exchanges.destroy

    respond_to do |format|
      format.html { redirect_to(exchanges_url) }
      format.xml  { head :ok }
    end
  end
end
