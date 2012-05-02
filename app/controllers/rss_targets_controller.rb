class RssTargetsController < ApplicationController
  layout "main"
    # GET /rss_targets
  # GET /rss_targets.xml
  def index
    @rss_targets = RssTarget.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rss_targets }
    end
  end

  # GET /rss_targets/1
  # GET /rss_targets/1.xml
  def show
    @rss_target = RssTarget.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rss_target }
    end
  end

  # GET /rss_targets/new
  # GET /rss_targets/new.xml
  def new
    @rss_target = RssTarget.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rss_target }
    end
  end

  # GET /rss_targets/1/edit
  def edit
    @rss_target = RssTarget.find(params[:id])
  end

  # POST /rss_targets
  # POST /rss_targets.xml
  def create
    @rss_target = RssTarget.new(params[:rss_target])
    @rss_target.last_processing_time = 0
    respond_to do |format|
      if @rss_target.save
        flash[:notice] = 'RssTarget was successfully created.'
        format.html { redirect_to(@rss_target) }
        format.xml  { render :xml => @rss_target, :status => :created, :location => @rss_target }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rss_target.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rss_targets/1
  # PUT /rss_targets/1.xml
  def update
    @rss_target = RssTarget.find(params[:id])
    @rss_target.last_processing_time = 0
    respond_to do |format|
      if @rss_target.update_attributes(params[:rss_target])
        flash[:notice] = 'RssTarget was successfully updated.'
        format.html { redirect_to(@rss_target) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rss_target.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rss_targets/1
  # DELETE /rss_targets/1.xml
  def destroy
    @rss_target = RssTarget.find(params[:id])
    @rss_target.destroy

    respond_to do |format|
      format.html { redirect_to(rss_targets_url) }
      format.xml  { head :ok }
    end
  end
end
